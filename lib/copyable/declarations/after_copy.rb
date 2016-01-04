module Copyable
  module Declarations
    class AfterCopy < Declaration

      def self.execute(after_copy_block, original_model, new_model)
        after_copy_block.call(original_model, new_model) if after_copy_block
      end

      def self.required?
        false
      end

    end
  end
end
