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

      it 'defines an instance variable on the class' do
        expect(CopyableTree.all_callbacks_disabled).to eq(true)
      end

      it 'should not prevent model actions from executing' do
        expect(CopyableTree.count).to eq(0)
      end
    end

    describe '.reenable!' do
      it 'defines an instance variable on the class' do
        Copyable::ModelHooks.reenable!(CopyableTree)
        expect(CopyableTree.all_callbacks_disabled).to eq(false)
      end

      it 'should allow callbacks to execute again' do
        expect {
          CopyableTree.create!(kind: 'magnolia')
        }.to raise_error(RuntimeError, "callback2 called")
      end
    end
  end
end
