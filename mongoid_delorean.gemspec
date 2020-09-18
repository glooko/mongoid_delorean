lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mongoid/delorean/version'

Gem::Specification.new do |gem|
  gem.name          = 'mongoid_delorean'
  gem.version       = Mongoid::Delorean::VERSION
  gem.authors       = ['Mark Bates']
  gem.email         = ['mark@markbates.com']
  gem.description   = 'A simple Mongoid versioning system that works with '\
                      'embedded documents.'
  gem.summary       = 'A simple Mongoid versioning system that works with '\
                      'embedded documents.'
  gem.homepage      = ''

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_dependency('mongoid', '>=7.0', '<8.0.0')

  gem.add_development_dependency('database_cleaner')
  gem.add_development_dependency('rake')
  gem.add_development_dependency('rspec')
end
