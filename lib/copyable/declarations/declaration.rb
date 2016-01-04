module Copyable
  module Declarations
    class Declaration

      def self.method_name
        self.name.demodulize.underscore
      end

      def self.required?
        true
      end

    end
  end
end
