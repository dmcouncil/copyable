module Copyable
  class OptionChecker

    VALID_OPTIONS = [:override, :skip_validations]
    VALID_PRIVATE_OPTIONS = [:__called_recursively]  # for copyable's internal use only

    def self.check!(options)
      unrecognized_options = options.keys - VALID_OPTIONS - VALID_PRIVATE_OPTIONS
      if unrecognized_options.any?
        message = "Unrecognized options passed to create_copy!:\n"
        unrecognized_options.each do |opt|
          message << "  #{opt.inspect}\n"
        end
        message << "The options passed to create_copy! can only be one of the following:\n"
        VALID_OPTIONS.each do |opt|
          message << "  #{opt.inspect}\n"
        end
        raise CopyableError.new(message)
      end
    end

  end
end
