module Copyable
  module Declarations
    class Associations < Declaration

      class << self

        # this is the algorithm for copying associated records according to the
        # instructions given in the copyable declaration
        def execute(association_list, original_model, new_model, skip_validations, skip_associations)
          @skip_validations = skip_validations
          association_list.each do |assoc_name, advice|
            association = original_model.class.reflections[assoc_name.to_s]
            check_advice(association, advice, original_model)
            unless advice == :do_not_copy || skip_associations.include?(assoc_name.to_sym)
              copy_association(association, original_model, new_model)
            end
          end
        end

      private

        def check_advice(association, advice, original_model)
          if ![:copy, :do_not_copy, :copy_only_habtm_join_records].include?(advice)
            message = "Error in copyable:associations of "
            message << "#{original_model.class.name}: the association '#{association.name}' "
            message << "has unrecognized advice '#{advice}'."
            raise AssociationError.new(message)
          end
          if association.macro == :has_and_belongs_to_many && advice == :copy
            message = "Error in copyable:associations of "
            message << "#{original_model.class.name}: the association '#{association.name}' "
            message << "only supports the :copy_only_habtm_join_records advice, not the :copy advice, "
            message << "because it is a has_and_belongs_to_many association."
            raise AssociationError.new(message)
          end
          if association.macro != :has_and_belongs_to_many && advice == :copy_only_habtm_join_records
            message = "Error in copyable:associations of "
            message << "#{original_model.class.name}: the association '#{association.name}' "
            message << "only supports the :copy advice, not the :copy_only_habtm_join_records advice, "
            message << "because it is not a has_and_belongs_to_many association."
            raise AssociationError.new(message)
          end
        end

        def copy_association(association, original_model, new_model)
          case association.macro
          when :has_many
            copy_has_many(association, original_model, new_model)
          when :has_one
            copy_has_one(association, original_model, new_model)
          when :has_and_belongs_to_many
            copy_habtm(association, original_model, new_model)
          else
            raise "Unsupported association #{association.macro}" # should never happen, since we filter out belongs_to
          end
        end

        def copy_has_many(association, original_model, new_model)
          original_model.send(association.name).each do |child|
            copy_record(association, child, new_model)
          end
        end

        def copy_has_one(association, original_model, new_model)
          child = original_model.send(association.name)
          copy_record(association, child, new_model) if child
        end

        def copy_habtm(association, original_model, new_model)
          original_model.send(association.name).each do |child|
            new_model.send(association.name) << child
          end
        end

        def copy_record(association, original_record, parent_model)
          if SingleCopyEnforcer.can_copy?(original_record)
            if original_record.respond_to? :create_copy!
              copied_record = original_record.create_copy!(
                override: { association.foreign_key => parent_model.id },
                __called_recursively: true,
                skip_validations: @skip_validations)
            else
              message = "Could not copy #{parent_model.class.name}#id:#{parent_model.id} "
              message << "because #{original_record.class.name} does not have a copyable declaration."
              raise Copyable::CopyableError.new(message)
            end
          else
            copied_record = CopyRegistry.fetch_copy(record: original_record)
            copied_record.update_column(association.foreign_key, parent_model.id)
          end
          update_other_belongs_to_associations(association.foreign_key, copied_record)
        end

        def update_other_belongs_to_associations(already_updated_key, copied_record)
          copied_record.class.reflect_on_all_associations(:belongs_to).each do |assoc|
            next if assoc.foreign_key == already_updated_key
            id = copied_record.send(assoc.foreign_key)
            if id
              if assoc.options.key? :polymorphic
                klass = copied_record.send("#{assoc.name}_type").constantize
              else
                klass = assoc.klass
              end
              copied_child = CopyRegistry.fetch_copy(class: klass, id: id)
              if copied_child
                copied_record.update_column(assoc.foreign_key, copied_child.id)
              end
            end
          end
        end

      end

    end
  end
end
