module Copyable
  module Declarations

    ALL = [ DisableAllCallbacksAndObserversExceptValidate,
            Columns,
            Associations,
            AfterCopy ]

    def self.include?(method_name)
      ALL.map(&:method_name).include?(method_name.to_s)
    end

  end
end
