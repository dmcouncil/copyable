require_relative 'helper/copyable_spec_helper'

describe 'Copyable.config' do
  it 'should be defined' do
    expect(Copyable).to respond_to(:config)
  end

  describe 'suppress_schema_errors' do
    it 'should default to false' do
      expect(Copyable.config.suppress_schema_errors).to be_falsey
    end

    it 'should be changeable' do
      Copyable.config.suppress_schema_errors = true
      expect(Copyable.config.suppress_schema_errors).to be_truthy
      Copyable.config.suppress_schema_errors = false
    end

    context 'when set to true' do
      before(:each) do
        Copyable.config.suppress_schema_errors = true
      end

      after(:each) do
        Copyable.config.suppress_schema_errors = false
      end

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

        it 'should not throw an error' do
          expect(@model_definition).to_not raise_error
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

        it 'should not throw an error' do
          expect(@model_definition).to_not raise_error
        end
      end

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

        it 'should not throw an error' do
          expect(@model_definition).to_not raise_error
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

        it 'should not throw an error' do
          expect(@model_definition).to_not raise_error
        end
      end
    end
  end
end
