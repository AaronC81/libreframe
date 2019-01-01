class Module
  # Similar to attr_accessor, but defines the reader method with a question
  # mark at the end of its name.
  # For example, bool_accessor(:x) would define #x? and #x=.
  # @param name [Symbol] The name of the boolean property, without a 
  #   question mark.
  def bool_accessor(name)
    bool_reader name
    attr_writer name
  end

  # Similar to attr_reader, but defines the method with a question mark at the
  # end of its name.
  # For example, bool_reader(:x) would define #x?.
  # @param name [Symbol] The name of the boolean property, without a 
  #   question mark.
  def bool_reader(name)
    define_method("#{name}?".to_sym) do
      instance_variable_get("@#{name}".to_sym)
    end
  end
end