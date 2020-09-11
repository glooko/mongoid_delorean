require 'mongoid/association/embedded/embedded_in'

module Mongoid
  module Association
    module Macros
      module ClassMethods
        alias embedded_in_without_history embedded_in
        def embedded_in(*args)
          relation = embedded_in_without_history(*args)
          send(:include, Mongoid::Delorean::Trackable::CommonInstanceMethods)
          send(:include, Mongoid::Delorean::Trackable::CommonEmbeddedMethods)
          before_save :save_version
          relation
        end
      end
    end
  end
end
