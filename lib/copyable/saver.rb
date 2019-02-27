module Copyable
  class Saver

    def self.direct_sql_insert!(new_model)
      new_model.send(:_create_record) # bypass all callbacks and validations
    end

    def self.direct_sql_update!(new_model)
      new_model.send(:_update_record) # bypass all callbacks and validations
    end

    # this is the algorithm for saving the new record
    def self.save!(new_model, skip_validations=false)
      unless skip_validations || new_model.valid?(:create)
        raise(ActiveRecord::RecordInvalid.new(new_model))
      end

      if new_model.class.all_callbacks_disabled && new_model.id.nil?
        self.direct_sql_insert!(new_model)
      elsif new_model.class.all_callbacks_disabled
        self.direct_sql_update!(new_model)
      else
        new_model.save!
      end
    end
  end
end
