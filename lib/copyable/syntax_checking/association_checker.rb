module Copyable
  class AssociationChecker < Copyable::CompletenessChecker

    def associations(associations)
      @associations = associations.keys.map(&:to_s)
    end

    private

    def expected_entries
      all_associations = model_class.reflect_on_all_associations
      required_associations = all_associations.select do |ass|
        (ass.macro != :belongs_to) && ass.options[:through].blank?
      end
      required_associations.map(&:name).map(&:to_s)
    end

    def provided_entries
      @associations
    end

    def missing_entries_found(missing_entries)
      message = "The following associations were not listed "
      message << "in copyable's associations in the model '#{model_class.name}':\n"
      missing_entries.each {|ass| message << "  association: #{ass}\n" }
      message << "Basically, if you just added a new association to this model, you need to update "
      message << "the copyable declaration to instruct it how to deal with copying the associated models.\n"
      raise AssociationError.new(message)
    end

    def extra_entries_found(extra_entries)
      message = "The following associations were listed in copyable's associations in the model '#{model_class.name}' "
      message << "but are either (1) not actually associations on this model or "
      message << "(2) an association that does not need to be listed "
      message << "(belongs to, has many through, or has one through):\n"
      extra_entries.each {|ass| message << "  association: #{ass}\n" }
      raise AssociationError.new(message)
    end

  end
end
