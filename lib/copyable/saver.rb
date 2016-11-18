module Copyable
  class Saver

    # this is the algorithm for saving the new record
    def self.save!(new_model, skip_validations)
      unless skip_validations
        ModelHooks.reenable!(new_model.class) # we must re-enable or validation does not work
        if !new_model.valid?(:create)
          ModelHooks.disable!(new_model.class)
          raise(ActiveRecord::RecordInvalid.new(new_model))
        else
          ModelHooks.disable!(new_model.class)
        end
      end
      new_model.save!(validate: !skip_validations)
    end

  end
end
