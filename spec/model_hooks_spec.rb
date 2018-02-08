require_relative 'helper/copyable_spec_helper'

describe Copyable::ModelHooks do
  context 'callbacks' do

    # Note: the relevant callbacks are defined in CopyableTree in helper/test_models.rb

    describe '.disable!' do
      before(:each) do
        Copyable::ModelHooks.disable!(CopyableTree)
      end
      after(:each) do
        Copyable::ModelHooks.reenable!(CopyableTree)
      end
      it 'should prevent callbacks from executing' do
        expect {
          CopyableTree.create!(kind: 'magnolia')
        }.to_not raise_error
      end
      it 'should not prevent model actions from executing' do
        expect(CopyableTree.count).to eq(0)
        CopyableTree.create!(kind: 'magnolia')
        expect(CopyableTree.count).to eq(1)
      end
    end

    describe '.reenable!' do
      it 'should allow callbacks to execute again' do
        Copyable::ModelHooks.disable!(CopyableTree)
        Copyable::ModelHooks.reenable!(CopyableTree)
        expect {
          CopyableTree.create!(kind: 'magnolia')
        }.to raise_error(RuntimeError, "callback2 called")
      end
    end
  end

  context 'validations' do

    # Note: the relevant model and observer class is defined in helper/test_models.rb

    describe '.disable!' do
      before(:each) do
        Copyable::ModelHooks.disable!(CopyableCoin)
      end
      after(:each) do
        Copyable::ModelHooks.reenable!(CopyableCoin)
      end
      it 'should prevent validations from executing' do
        expect {
          CopyableCoin.create!(year: -10)
        }.to_not raise_error
      end
      it 'should not prevent model actions from executing' do
        expect(CopyableCoin.count).to eq(0)
        CopyableCoin.create!(year: -10)
        expect(CopyableCoin.count).to eq(1)
      end
    end

    describe '.reenable!' do
      it 'should allow validations to execute again' do
        Copyable::ModelHooks.disable!(CopyableCoin)
        Copyable::ModelHooks.reenable!(CopyableCoin)
        expect {
          CopyableCoin.create!(year: -10)
        }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end
  end

  describe 'nested disables and enables' do
    it 'should allow callbacks to execute again' do
      Copyable::ModelHooks.disable!(CopyableTree)
      expect { CopyableTree.create!(kind: 'magnolia') }.to_not raise_error

      Copyable::ModelHooks.disable!(CopyableCoin)
      expect { CopyableCoin.create!(year: -10) }.to_not raise_error

      Copyable::ModelHooks.disable!(CopyableTree)
      expect { CopyableTree.create!(kind: 'magnolia') }.to_not raise_error

      Copyable::ModelHooks.reenable!(CopyableCoin)
      expect { CopyableCoin.create!(year: -10) }.to raise_error(ActiveRecord::RecordInvalid)

      Copyable::ModelHooks.reenable!(CopyableTree)
      expect { CopyableTree.create!(kind: 'magnolia') }.to raise_error(RuntimeError)

      Copyable::ModelHooks.reenable!(CopyableTree)
      expect { CopyableTree.create!(kind: 'magnolia') }.to raise_error(RuntimeError)
    end
  end
end
