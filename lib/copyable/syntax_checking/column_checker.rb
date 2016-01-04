module Copyable
  class ColumnChecker < Copyable::CompletenessChecker

    def columns(columns)
      @columns = columns.keys.map(&:to_s)
    end

    private

    def columns_to_skip
      ['id', 'created_at', 'updated_at', 'created_on', 'updated_on']
    end

    def expected_entries
      columns_in_database = model_class.column_names
      columns_in_database -= columns_to_skip
      columns_in_database
    end

    def provided_entries
      @columns
    end

    def missing_entries_found(missing_entries)
      message = "The following columns were found in the database table '#{model_class.table_name}' "
      message << "but not found in copyable's columns in the model '#{model_class.name}':\n"
      missing_entries.each {|c| message << "  column: #{c}\n" }
      message << "Basically, if you just added columns to this database table, you need to update "
      message << "the copyable declaration to instruct it how to copy the new columns.\n"
      raise ColumnError.new(message)
    end

    def extra_entries_found(extra_entries)
      message = "The following columns were found in copyable's columns in the model '#{model_class.name}' "
      message << "but not found in the database table '#{model_class.table_name}':\n"
      extra_entries.each {|c| message << "  column: #{c}\n" }
      message << "Note that the #{columns_to_skip.join(', ')} columns are handled "
      message << "automatically and should not be listed.\n"
      raise ColumnError.new(message)
    end

  end
end
