module Copyable
  class OptionChecker

    VALID_OPTIONS = [:override, :global_override, :skip_validations, :skip_associations]
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
      # :skip_associations needs to be an array if it's present
      if (options[:skip_associations].present? && !options[:skip_associations].is_a?(Array))
        raise CopyableError.new("When :skip_associations is used, it must be an array")
      end
    end

  end
end
