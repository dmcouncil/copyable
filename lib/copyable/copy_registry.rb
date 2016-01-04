# Refer to the comments in SingleCopyEnforcer to understand why we need
# this class.
#
# Also note that the way this class is implemented, all records being copied
# are kept in memory.  For copying extremely large record trees, memory
# could be an issue, in which case this algorithm may need refactoring.
#
module Copyable
  class CopyRegistry

    class << self

      def register(original_record, new_record)
        @registry ||= {}
        key = make_hash(record: original_record)
        @registry[key] = new_record
      end

      def already_copied?(options)
        fetch_copy(options).present?
      end

      def fetch_copy(options)
        @registry ||= {}
        key = make_hash(options)
        @registry[key]
      end

      def clear
        @registry = {}
      end

    private

      def make_hash(options)
        if options[:record]
          id = options[:record].id
          klass = options[:record].class
        else
          id = options[:id]
          klass = options[:class]
        end
        raise "Record has no id" if id.nil?
        "#{klass.name}-#{id}"
      end

    end

  end
end
