module Copyable
  class ModelHooks

    # Disabling callbacks automatically disables any registered observers,
    # since observers use the callback mechanism internally.

    def self.disable!(klass)
      disable_all_callbacks(klass)
    end

    def self.reenable!(klass)
      reenable_all_callbacks(klass)
    end

  private

    def self.disable_all_callbacks(klass)
      klass.class_eval do
        return if self.method_defined? :old_save! # Don't do this more than once

        @all_callbacks_disabled = true
        class << self
          attr_reader :all_callbacks_disabled
        end

        alias_method :old_save!, :save!

        # Hold my beer while we bypass all the Rails callbacks
        # in favor of some raw SQL
        def save!
          Copyable::Saver.save!(self)
        end
      end
    end

    def self.reenable_all_callbacks(klass)
      klass.class_eval do
        return unless self.method_defined? :old_save! # Don't do this more than once
        @all_callbacks_disabled = false
        class << self
          attr_reader :all_callbacks_disabled
        end

        alias_method :save!, :old_save!
        remove_method :old_save!
      end
    end

  end
end
