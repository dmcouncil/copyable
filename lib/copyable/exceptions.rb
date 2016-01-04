module Copyable

  class CopyableError < StandardError; end

  class DeclarationError < CopyableError; end
  class ColumnError < CopyableError; end
  class AssociationError < CopyableError; end
  class CallbackError < CopyableError; end

end
