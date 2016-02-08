require_relative 'helper/copyable_spec_helper'

# Even though we have good specs that test the syntax checker classes
# individually, we still need the specs in this file to make sure the syntax
# checking is hooked up properly to the copyable declaration.

describe 'syntax checking' do



  #*****************************************************************************
  # COPYABLE

  context 'copyable' do
    it 'should throw an error when passed no block' do
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable
        end
      end
      expect(model_definition).to raise_error(Copyable::CopyableError)
    end

    it 'should throw an error when passed an empty block' do
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
          end
        end
      end
      expect(model_definition).to raise_error(Copyable::DeclarationError)
    end

    it 'should not throw an error when all required declarations are present' do
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
            disable_all_callbacks_and_observers_except_validate
            columns({
              kind:  :copy,
              year:  :copy,
            })
            associations({
            })
          end
        end
      end
      expect(model_definition).to_not raise_error
    end

    it 'should not throw an error when all declarations are present' do
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
            disable_all_callbacks_and_observers_except_validate
            columns({
              kind:  :copy,
              year:  :copy,
            })
            associations({
            })
            after_copy do |original_model, new_model|
            end
          end
        end
      end
      expect(model_definition).to_not raise_error
    end

    it 'should throw an error when an unknown declaration is present' do
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
            disable_all_callbacks_and_observers_except_validate
            columns({
              kind:  :copy,
              year:  :copy,
            })
            associations({
            })
            what_the_heck_is_this_doing_here
          end
        end
      end
      expect(model_definition).to raise_error(Copyable::DeclarationError)
    end

    it 'should throw an error if a required declaration is missing' do
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
            # MISSING disable_all_callbacks_and_observers_except_validate
            columns({
              kind:  :copy,
              year:  :copy,
            })
            associations({
            })
          end
        end
      end
      expect(model_definition).to raise_error(Copyable::DeclarationError)
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
            disable_all_callbacks_and_observers_except_validate
            # MISSING columns({
            #   kind:  :copy,
            #   year:  :copy,
            # })
            associations({
            })
          end
        end
      end
      expect(model_definition).to raise_error(Copyable::DeclarationError)
      model_definition = lambda do
        undefine_copyable_in CopyableCoin
        class CopyableCoin < ActiveRecord::Base
          copyable do
            disable_all_callbacks_and_observers_except_validate
            columns({
              kind:  :copy,
              year:  :copy,
            })
            # MISSING associations({
            # })
          end
        end
      end
      expect(model_definition).to raise_error(Copyable::DeclarationError)
    end
  end



  #*****************************************************************************
  # COLUMNS

  context 'copyable:columns' do
    context 'when missing columns' do
      before(:each) do
        @model_definition = lambda do
          undefine_copyable_in CopyableCoin
          class CopyableCoin < ActiveRecord::Base
            copyable do
              disable_all_callbacks_and_observers_except_validate
              columns({
                kind:  :copy,
              })
              associations({
              })
            end
          end
        end
      end

      it 'should throw an error' do
        expect(@model_definition).to raise_error(Copyable::ColumnError)
      end
    end

    context 'with unknown columns' do
      before(:each) do
        @model_definition = lambda do
          undefine_copyable_in CopyableCoin
          class CopyableCoin < ActiveRecord::Base
            copyable do
              disable_all_callbacks_and_observers_except_validate
              columns({
                what_is_this_column_doing_here:  :copy,
                kind:                            :copy,
                year:                            :copy,
              })
              associations({
              })
            end
          end
        end
      end

      it 'should throw an error' do
        expect(@model_definition).to raise_error(Copyable::ColumnError)
      end
    end
  end



  #*****************************************************************************
  # ASSOCIATIONS

  context 'copyable:associations' do
    context 'when missing associations' do
      before(:each) do
        @model_definition = lambda do
          class CopyablePet < ActiveRecord::Base
            copyable do
              disable_all_callbacks_and_observers_except_validate
              columns({
                name:        :copy,
                kind:        :copy,
                birth_year:  :copy,
              })
              associations({
                # MISSING copyable_toys:                    :copy,
                copyable_pet_tag:                 :copy,
                copyable_pet_profile:             :copy,
                copyable_pet_foods:               :copy,
                copyable_pet_sitting_patronages:  :copy,
              })
            end
          end
        end
      end

      it 'should throw an error' do
        expect(@model_definition).to raise_error(Copyable::AssociationError)
      end
    end

    context 'with unknown associations' do
      before(:each) do
        @model_definition = lambda do
          class CopyablePet < ActiveRecord::Base
            copyable do
              disable_all_callbacks_and_observers_except_validate
              columns({
                name:        :copy,
                kind:        :copy,
                birth_year:  :copy,
              })
              associations({
                this_assoc_should_not_be_here:    :copy,
                copyable_toys:                    :copy,
                copyable_pet_tag:                 :copy,
                copyable_pet_profile:             :copy,
                copyable_pet_foods:               :copy,
                copyable_pet_sitting_patronages:  :copy,
              })
            end
          end
        end
      end

      it 'should throw an error' do
        expect(@model_definition).to raise_error(Copyable::AssociationError)
      end
    end
  end
end
