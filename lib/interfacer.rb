# @api private
class InterfaceSpec
  def initialize(required_interface_methods)
    @required_interface_methods = required_interface_methods
  end

  def missing_methods(tested_class)
    @required_interface_methods.reject do |method_name|
      if method_name[0] == '.' # Prefered for classes.
        tested_class.respond_to?(method_name[1..-1])
      elsif method_name.is_a?(Symbol) # Prefered for objects.
        tested_class.respond_to?(method_name)
      elsif method_name[0] == '#'
        tested_class.instance_methods.include?(method_name[1..-1].to_sym)
      else
        raise ArgumentError.new("Incorrect method name. Method name must start with either . or #, such as .new or #to_s OR to be a symbol.")
      end
    end
  end

  def fullfills_interface?(tested_class)
    self.missing_methods(tested_class).empty?
  end
end

# @api public
class InterfaceRequirementsNotMetError < StandardError
  def initialize(attr_name, missing_methods)
    super("Attribute #{attr_name} expects #{missing_methods.inspect} to be defined.")
  end
end

# @api public
module Interfacer
  def interface_specs_for_attrs
    @interface_specs_for_attrs ||= Hash.new
  end

  def attribute(attr_name, *required_methods, &block)
    interface_specs_for_attrs[attr_name] = InterfaceSpec.new(required_methods)

    define_method(attr_name) do
      value = instance_variable_get(:"@#{attr_name}")
      return value if value
      instance_variable_set(:"@#{attr_name}", block.call) if block
    end

    define_method(:"#{attr_name}=") do |value|
      spec = self.class.interface_specs_for_attrs[attr_name]

      unless spec.fullfills_interface?(value)
        raise InterfaceRequirementsNotMetError.new(attr_name, spec.missing_methods(value))
      end

      instance_variable_set(:"@#{attr_name}", value)
    end
  end
end

export Interfacer: Interfacer,
       InterfaceRequirementsNotMetError: InterfaceRequirementsNotMetError
