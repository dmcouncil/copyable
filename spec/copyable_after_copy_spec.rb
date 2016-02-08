require_relative 'helper/copyable_spec_helper'

describe 'copyable:after_copy' do
  before(:each) do
    undefine_copyable_in CopyableCoin
    class CopyableCoin < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          kind:  lambda { |orig| "Copy of #{orig.kind}" },
          year:  :copy,
        })
        associations({
        })
        after_copy do |original_model, new_model|
          raise "#{original_model.kind} #{new_model.kind}"
        end
      end
    end
  end

  it 'should execute the after_copy block after copying' do
    coin = CopyableCoin.create!(kind: 'nickel', year: 1883)
    expect {
      coin.create_copy!
    }.to raise_error(RuntimeError, "nickel Copy of nickel")
  end
end
