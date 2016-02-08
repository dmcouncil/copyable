require_relative 'helper/copyable_spec_helper'

describe 'a model hierarchy with lots of variations in copyable behavior' do
  before(:each) do

    #***************************************************************************
    #  Define all of the copyable declarations.

    undefine_copyable_in CopyablePet
    class CopyablePet < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:        :copy,
          kind:        :copy,
          birth_year:  lambda { |orig| orig.birth_year + 1 },
        })
        associations({
          copyable_toys:                    :do_not_copy,
          copyable_pet_tag:                 :copy,
          copyable_pet_profile:             :copy,
          copyable_pet_foods:               :copy_only_habtm_join_records,
          copyable_pet_sitting_patronages:  :copy,
        })
      end
    end

    undefine_copyable_in CopyableToy
    class CopyableToy < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:             :copy,
          kind:             :copy,
          copyable_pet_id:  :copy,
        })
        associations({
        })
      end
    end

    undefine_copyable_in CopyablePetTag
    class CopyablePetTag < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          registered_name:  :copy,
          copyable_pet_id:  :copy,
        })
        associations({
        })
      end
    end

    undefine_copyable_in CopyablePetFood
    class CopyablePetFood < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:  :copy,
        })
        associations({
          copyable_pets:  :copy_only_habtm_join_records,
        })
      end
    end

    undefine_copyable_in CopyablePetSitter
    class CopyablePetSitter < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:  :copy,
        })
        associations({
          copyable_pet_sitting_patronages:  :copy,
        })
        after_copy do |original_model, new_model|
          new_model.name = new_model.name + '*'
          new_model.save!
        end
      end
    end

    undefine_copyable_in CopyablePetSittingPatronage
    class CopyablePetSittingPatronage < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          copyable_pet_id:        :copy,
          copyable_pet_sitter_id: :copy,
        })
        associations({
        })
      end
    end

    undefine_copyable_in CopyablePetProfile
    class CopyablePetProfile < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          description:      lambda { |orig| 'overwrite' },
          nickname:         :do_not_copy,
          copyable_pet_id:  :copy,
        })
        associations({
          copyable_address:  :copy,
        })
      end
    end

    undefine_copyable_in CopyableAddress
    class CopyableAddress < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          address1:                 :copy,
          address2:                 :copy,
          city:                     :copy,
          state:                    :copy,
          copyable_pet_profile_id:  :copy,
        })
        associations({
        })
      end
    end

    #***************************************************************************
    #  Create the models.

    # foods
    @chow_mix = CopyablePetFood.create!(name: 'chow mix')
    @mushy_food = CopyablePetFood.create!(name: 'mushy food')
    @meal_scraps = CopyablePetFood.create!(name: 'meal scraps')

    # sitters
    @marty = CopyablePetSitter.create!(name: 'Martin Luther King, Jr.')
    @bob = CopyablePetSitter.create!(name: 'Robert Frost')
    @bubba = CopyablePetSitter.create!(name: 'William Jefferson Clinton')

    # Rover
    @rover = CopyablePet.create!(
      name: 'Rover',
      kind: 'canine',
      birth_year: 2009)
    @plastic_bone = CopyableToy.create!(
      name: 'favorite bone',
      kind: 'plastic squeaky toy',
      copyable_pet: @rover)
    @rovers_tag = CopyablePetTag.create!(
      registered_name: 'Rover McSmith #3872D',
      copyable_pet: @rover)
    @rovers_profile = CopyablePetProfile.create!(
      description: 'part Dachshund, part Great Dane, totally badass',
      nickname: 'Wubby Wubby Roverkins',
      copyable_pet: @rover)
    @rovers_address = CopyableAddress.create!(
      address1: '5 Maple St',
      city: 'Mapleton',
      state: 'MA',
      copyable_pet_profile: @rovers_profile)
    @rover_bubba_patronage = CopyablePetSittingPatronage.create!(
      copyable_pet: @rover,
      copyable_pet_sitter: @bubba)
    @rover.copyable_pet_foods << @chow_mix
    @rover.copyable_pet_foods << @meal_scraps

    # Toonces
    @toonces = CopyablePet.create!(
      name: 'toonces',
      kind: 'feline',
      birth_year: 2005)
    @yarn = CopyableToy.create!(
      name: 'red yarn',
      kind: 'just yarn',
      copyable_pet: @toonces)
    @toonces_tag = CopyablePetTag.create!(
      registered_name: 'Toonces McSmith #3879F',
      copyable_pet: @toonces)
    @toonces_profile = CopyablePetProfile.create!(
      description: 'really bad driver',
      nickname: '*$#!',
      copyable_pet: @toonces)
    @tooncess_address = CopyableAddress.create!(
      address1: '5 Maple St #2',
      city: 'Mapleton',
      state: 'MA',
      copyable_pet_profile: @toonces_profile)
    @toonces_bubba_patronage = CopyablePetSittingPatronage.create!(
      copyable_pet: @toonces,
      copyable_pet_sitter: @bubba)
    @toonces_marty_patronage = CopyablePetSittingPatronage.create!(
      copyable_pet: @toonces,
      copyable_pet_sitter: @marty)
    @toonces.copyable_pet_foods << @mushy_food
  end

  it 'should copy without error' do
    expect {
      @rover.create_copy!
      @toonces.create_copy!
    }.to_not raise_error
  end

  it 'should not copy toys' do
    expect(CopyableToy.count).to eq(2)
    @rover.create_copy!
    @toonces.create_copy!
    expect(CopyableToy.count).to eq(2)
  end

  it 'should not copy pet profile nickname' do
    copied_rover = @rover.create_copy!
    expect(copied_rover.copyable_pet_profile.nickname).to be_nil
  end

  it 'should not copy pet sitters when copying pets' do
    expect(CopyablePetSitter.count).to eq(3)
    @rover.create_copy!
    @toonces.create_copy!
    expect(CopyablePetSitter.count).to eq(3)
  end

  it 'should add a * to the pet sitter name after copying' do
    expect(@marty.create_copy!.name).to eq('Martin Luther King, Jr.*')
    expect(@bob.create_copy!.name).to eq('Robert Frost*')
  end

  it 'should allow columns to be overriden' do
    copied_rover = @rover.create_copy!(
      override: {
        name: 'overridden name',
        kind: 'overridden kind',
        birth_year: 1900 })
    expect(copied_rover.name).to eq('overridden name')
    expect(copied_rover.kind).to eq('overridden kind')
    expect(copied_rover.birth_year).to eq(1900)
  end

  it 'should allow multiple copying' do
    expect {
      3.times { @rover.create_copy! }
    }.to_not raise_error
  end

  it 'should have exactly the expected records after copying' do
    @rover.create_copy!
    expect(CopyablePet.count).to eq(3)
    expect(CopyablePet.where(name: 'Rover').count).to eq(2)
    expect(CopyableToy.count).to eq(2)
    expect(CopyablePetTag.count).to eq(3)
    expect(CopyablePetTag.where(registered_name: 'Rover McSmith #3872D').count).to eq(2)
    expect(CopyablePetFood.count).to eq(3)
    expect(CopyablePetSitter.count).to eq(3)
    expect(CopyablePetSittingPatronage.count).to eq(4)
    expect(CopyablePetProfile.count).to eq(3)
    expect(CopyableAddress.count).to eq(3)
    expect(CopyableAddress.where(address1: '5 Maple St').count).to eq(2)
  end
end
