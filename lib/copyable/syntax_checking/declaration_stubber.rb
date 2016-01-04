module Copyable
  module DeclarationStubber

    # This creates dummy methods for each declaration, which is useful
    # if you are creating a class that merely wants to check that
    # a particular declaration is called correctly.  It's useful to
    # have the other declarations that you don't care about available
    # as stubs.
    def self.included(klass)
      Declarations::ALL.each do |decl|
        klass.send(:define_method, decl.method_name) do |*args|
          # intentionally empty
        end
      end
    end

  end
end
