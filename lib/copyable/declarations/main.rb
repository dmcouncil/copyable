module Copyable
  module Declarations
    class Main

      attr_reader :column_list, :association_list, :after_copy_block

      def execute(block)
        self.instance_eval(&block)
      end

      # This declaration doesn't actually *do* anything.  It exists
      # so that any copyable declaration must explicitly state that
      # callbacks and observers are skipped (to make it easier to reason
      # about the code when it is read).
      def disable_all_callbacks_and_observers_except_validate
      end

      def columns(columns)
        @column_list = columns
      end

      def associations(associations)
        @association_list = associations
      end

      def after_copy(&block)
        @after_copy_block = block
      end

    end
  end
end
