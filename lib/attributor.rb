require 'json'
require 'randexp'

require 'hashie'

require 'digest/sha1'

if Gem::Version.new(RUBY_VERSION.dup) < Gem::Version.new("1.9")
  # Method require_relative was added in Ruby 1.9, so use the gem
  # if we have a Ruby version less than 1.9
  require 'require_relative'
  # Needed so that 'bundle exec rake rcov' actually runs the specs
  require 'rspec/autorun'
end

module Attributor

  require_relative 'attributor/exceptions'
  require_relative 'attributor/attribute'
  require_relative 'attributor/type'
  require_relative 'attributor/dsl_compiler'
  require_relative 'attributor/attribute_resolver'

  require_relative 'attributor/extensions/core'
  require_relative 'attributor/extensions/randexp'

  require_relative 'attributor/types/object'
  require_relative 'attributor/types/integer'
  require_relative 'attributor/types/string'
  require_relative 'attributor/types/model'
  require_relative 'attributor/types/struct'
  require_relative 'attributor/types/boolean'
  require_relative 'attributor/types/date_time'
  require_relative 'attributor/types/float'
  require_relative 'attributor/types/collection'

  # List of all basic types (i.e. not collections, structs or models)

  # hierarchical separator string for composing human readable attributes
  SEPARATOR = '.'.freeze

  # @param type [Class] The class of the type to resolve
  #
  def self.resolve_type(attr_type, options={}, constructor_block=nil)
    if attr_type < Attributor::Type
      klass = attr_type
    else
      name = attr_type.name.split("::").last # TOO EXPENSIVE?

      klass = const_get(name) if const_defined?(name)
      raise AttributorException.new("Could not find class with name #{name}") unless klass
      raise AttributorException.new("Could not find attribute type for: #{name} [klass: #{klass.name}]")  unless  klass < Attributor::Type
    end

    if klass.respond_to?(:construct)
      return klass.construct(constructor_block, options)
    end

    raise AttributorException.new("Type: #{attr_type} does not support anonymous generation") if constructor_block

    klass
  end

end
