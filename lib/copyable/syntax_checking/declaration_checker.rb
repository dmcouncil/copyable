module Copyable
  class DeclarationChecker

    def verify!(declaration_block)
      @declarations_that_were_called = []
      self.instance_eval(&declaration_block)

      Copyable::Declarations::ALL.each do |declaration|
        if declaration.required? && !@declarations_that_were_called.include?(declaration.method_name)
          message = "The copyable declaration must include #{declaration.name}."
          raise DeclarationError.new(message)
        end
      end
    end

    def method_missing(method_name, *args, &block)
      method = method_name.to_s
      if Copyable::Declarations.include?(method)
        @declarations_that_were_called << method
      else
        raise DeclarationError.new("Unknown declaration '#{method}' in copyable.")
      end
    end

  end
end
