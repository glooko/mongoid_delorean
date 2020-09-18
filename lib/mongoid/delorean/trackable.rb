module Mongoid
  module Delorean
    module Trackable
      def self.included(klass)
        super
        klass.field :version, type: Integer, default: 0
        klass.before_save :save_version
        klass.after_save :after_save_version
        klass.send(:include, Mongoid::Delorean::Trackable::CommonInstanceMethods)
      end

      def versions
        Mongoid::Delorean::History.where(original_class: self.class.name,
                                         original_class_id: id)
                                  .order_by(version: 'asce')
      end

      def save_version
        if track_history?
          last_version = versions.last
          _version = last_version ? last_version.version + 1 : 1

          _attributes = attributes_with_relations
          _attributes['version'] = _version
          _changes = changes_with_relations.dup
          _changes['version'] = [version_was, _version]

          Mongoid::Delorean::History.create(original_class: self.class.name,
                                            original_class_id: id,
                                            version: _version,
                                            altered_attributes: _changes,
                                            full_attributes: _attributes)
          without_history_tracking do
            self.version = _version
            unless new_record?
              if ::Mongoid.const_defined? :Observer
                set(:version, _version)
              else
                set(version: _version)
              end
            end
          end

          @__track_changes = false
        end

        true
      end

      def after_save_version
        @__track_changes = Mongoid::Delorean.config.track_history
      end

      def track_history?
        @__track_changes.nil? ? Mongoid::Delorean.config.track_history : @__track_changes
      end

      def without_history_tracking
        previous_track_change = @__track_changes
        @__track_changes = false
        yield
        @__track_changes = previous_track_change
      end

      def revert!(version = (self.version - 1))
        old_version = versions.where(version: version).first
        if old_version
          old_version.full_attributes.each do |key, value|
            write_attribute(key, value)
          end
          save!
        end
      end

      module CommonEmbeddedMethods
        def save_version
          if _parent.respond_to?(:save_version)
            if _parent.respond_to?(:track_history?)
              _parent.save_version if _parent.track_history?
            else
              _parent.save_version
            end
          end

          true
        end
      end

      module CommonInstanceMethods
        def changes_with_relations
          _changes = changes.dup

          %w[version updated_at created_at].each do |col|
            _changes.delete(col)
            _changes.delete(col.to_sym)
          end

          relation_changes = {}
          embedded_relations.each do |name, details|
            relation = send(name)
            relation_changes[name] = []
            if details.is_a? Mongoid::Association::Embedded::EmbedsOne
              relation_changes[name] = relation.changes_with_relations if relation
            else
              r_changes = relation.map { |o| o.changes_with_relations }
              relation_changes[name] << r_changes unless r_changes.empty?
              relation_changes[name].flatten!
            end
            relation_changes.delete(name) if relation_changes[name].empty?
          end

          _changes.merge!(relation_changes)
          _changes
        end

        def attributes_with_relations
          _attributes = attributes.dup

          relation_attrs = {}
          embedded_relations.each do |name, details|
            relation = send(name)
            if details.is_a? Mongoid::Association::Embedded::EmbedsOne
              relation_attrs[name] = relation.attributes_with_relations if relation
            else
              relation_attrs[name] = []
              r_attrs = relation.map { |o| o.attributes_with_relations }
              relation_attrs[name] << r_attrs unless r_attrs.empty?
              r_changes = relation.map { |o| o.changes }
              relation_attrs[name].flatten!
            end
          end
          _attributes.merge!(relation_attrs)
          _attributes
        end
      end
    end
  end
end
