module Copyable
  class SyntaxChecker

    def self.check!(model_class, declaration_block)
      raise CopyableError.new("You must pass copyable a block") if declaration_block.nil?
      declaration_checker = DeclarationChecker.new
      declaration_checker.verify!(declaration_block)
      column_checker = ColumnChecker.new(model_class)
      column_checker.verify!(declaration_block)
      association_checker = AssociationChecker.new(model_class)
      association_checker.verify!(declaration_block)
    end

  end
end
