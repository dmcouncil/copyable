module Copyable
  module Declarations
    class Columns < Declaration

      # this is the algorithm for copying columns from the original record
      # to the brand new copy of the record according to the instructions
      # given in the copyable declaration
      def self.execute(column_list, original_model, new_model, overrides)
        column_list.each do |column, advice|
          # when create_copy! is called, you can pass in a hash of
          # overrides that trumps the instructions in the copyable
          # declaration
          if overrides[column.to_sym].present?
            value = overrides[column.to_sym]
          elsif overrides[column.to_s].present?
            value = overrides[column.to_s]
          elsif advice == :copy
            value = original_model.send(column)
          elsif advice == :do_not_copy
            value = nil
          elsif advice.is_a? Proc
            value = advice.call(original_model)
          else
            message = "Error in copyable:columns of #{original_model.class.name}: "
            message << "the column '#{column}' must be :copy, :do_not_copy, or a lambda."
            raise ColumnError.new(message)
          end
          new_model.send("#{column}=", value)
        end
      end

    end
  end
end
