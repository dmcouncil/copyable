require_relative '../helper/copyable_spec_helper'

describe Copyable::AssociationChecker do

  it 'should not throw an error if all associations are present' do
    block = Proc.new do
      associations({
        copyable_pets: :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePetFood)
    expect { association_checker.verify!(block) }.to_not raise_error
  end

  it 'should throw an error if unrecognized associations are present' do
    block = Proc.new do
      associations({
        copyable_pets: :copy,
        what_is_this:  :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePetFood)
    expect { association_checker.verify!(block) }.to raise_error(Copyable::AssociationError)
  end

  it 'should not require "has many through" or "has one through" relationships to be listed' do
    block = Proc.new do
      associations({
        copyable_toys:                    :copy,
        copyable_pet_tag:                 :copy,
        copyable_pet_profile:             :copy,
        copyable_pet_foods:               :copy,
        copyable_pet_sitting_patronages:  :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePet)
    expect { association_checker.verify!(block) }.to_not raise_error
  end

  it 'should not require "belongs to" relationships to be listed' do
    block = Proc.new do
      associations({
        copyable_address:  :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePetProfile)
    expect { association_checker.verify!(block) }.to_not raise_error
  end

  it 'should require "has one" relationships to be listed' do
    block = Proc.new do
      associations({
        # MISSING copyable_address:  :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePetProfile)
    expect { association_checker.verify!(block) }.to raise_error(Copyable::AssociationError)
  end

  it 'should require "has many" relationships to be listed' do
    block = Proc.new do
      associations({
        # MISSING copyable_pet_sitting_patronages:  :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePetSitter)
    expect { association_checker.verify!(block) }.to raise_error(Copyable::AssociationError)
  end

  it 'should require "has and belongs to many" relationships to be listed' do
    block = Proc.new do
      associations({
        # MISSING copyable_pets:  :copy,
      })
    end
    association_checker = Copyable::AssociationChecker.new(CopyablePetFood)
    expect { association_checker.verify!(block) }.to raise_error(Copyable::AssociationError)
  end

end
