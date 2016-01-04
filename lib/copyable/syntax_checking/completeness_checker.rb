module Copyable
  class CompletenessChecker

    include DeclarationStubber

    def initialize(model_class)
      @model_class = model_class
    end

    # an algorithm for ensuring that the expected entries are listed
    # in a declaration -- no more, and no less
    def verify!(block)
      self.instance_eval(&block)
      expected = Set.new(expected_entries)
      provided = Set.new(provided_entries)
      missing_entries = expected - provided
      extra_entries = provided - expected
      missing_entries_found(missing_entries) if missing_entries.any?
      extra_entries_found(extra_entries) if extra_entries.any?
    end

    private

    def model_class; @model_class; end

  end
end
