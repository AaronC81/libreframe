class Module
  # Similar to attr_accessor, but defines the reader method with a question
  # mark at the end of its name.
  # For example, bool_accessor(:x) would define #x? and #x=.
  # @param name [Symbol] The name of the boolean property, without a 
  #   question mark.
  def bool_accessor(*names)
    bool_reader *names
    attr_writer *names
  end

  # Similar to attr_reader, but defines the method with a question mark at the
  # end of its name.
  # For example, bool_reader(:x) would define #x?.
  # @param name [Symbol] The name of the boolean property, without a 
  #   question mark.
  def bool_reader(*names)
    names.each do |name|
      define_method("#{name}?".to_sym) do
        instance_variable_get("@#{name}".to_sym)
      end
    end
  end
end