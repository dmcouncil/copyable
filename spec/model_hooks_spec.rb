require_relative 'helper/copyable_spec_helper'

describe Copyable::ModelHooks do
  context 'callbacks' do

    # Note: the relevant callbacks are defined in CopyableTree in helper/test_models.rb

    describe '.disable!' do
      before(:each) do
        puts "Dennis before!"
        Copyable::ModelHooks.disable!(CopyableTree)
      end
      after(:each) do
        puts "Dennis after"
        Copyable::ModelHooks.reenable!(CopyableTree)
      end
      it 'should prevent callbacks from executing' do
        puts "Dennis 1"
        expect {
          tree = CopyableTree.create!(kind: 'magnolia')
        }.to_not raise_error
        puts "Dennis 2"
      end
      it 'should not prevent model actions from executing' do
        puts "Dennis 4"
        expect(CopyableTree.count).to eq(0)
        tree = CopyableTree.create!(kind: 'magnolia')
        expect(CopyableTree.count).to eq(1)
      end
    end

    describe '.reenable!' do
      it 'should allow callbacks to execute again' do
        Copyable::ModelHooks.disable!(CopyableTree)
        Copyable::ModelHooks.reenable!(CopyableTree)
        expect {
          tree = CopyableTree.create!(kind: 'magnolia')
        }.to raise_error(RuntimeError, "callback2 called")
      end
    end
  end

  context 'observers' do

    # Note: the relevant model and observer class is defined in helper/test_models.rb

    describe '.disable!' do
      before(:each) do
        Copyable::ModelHooks.disable!(CopyableCar)
      end
      after(:each) do
        Copyable::ModelHooks.reenable!(CopyableCar)
      end
      it 'should prevent observers from executing' do
        expect {
          car = CopyableCar.create!(make: 'Ferrari', model: 'California', year: 2009)
        }.to_not raise_error
      end
      it 'should not prevent model actions from executing' do
        expect(CopyableCar.count).to eq(0)
        car = CopyableCar.create!(make: 'Ferrari', model: 'California', year: 2009)
        expect(CopyableCar.count).to eq(1)
      end
    end
  end
end
