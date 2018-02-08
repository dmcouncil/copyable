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
        # Don't do it if it was already done
        return if self.method_defined? :__disabled__run_callbacks

        alias_method :__disabled__run_callbacks, :run_callbacks
        # We are violently duck-punching ActiveRecord because ActiveRecord
        # gives us no way to turn off callbacks.  My apologies to the
        # squeamish.
        def run_callbacks(kind, *args, &block)
          if block_given?
            yield
          else
            true
          end
        end
      end
    end

    def self.reenable_all_callbacks(klass)
      klass.class_eval do
        # Only do it if the disabled callbacks are defined
        return unless self.method_defined? :__disabled__run_callbacks

        alias_method :run_callbacks, :__disabled__run_callbacks
        remove_method :__disabled__run_callbacks
      end
    end

  end
end
