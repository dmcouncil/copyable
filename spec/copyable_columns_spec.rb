require_relative 'helper/copyable_spec_helper'

describe 'copyable:columns' do
  context 'when asked to do a simple column copy' do
    include ActiveSupport::Testing::TimeHelpers

    before(:each) do
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

    it 'should create a new record with matching columns' do
      expect(CopyableCoin.count).to eq(0)
      coin = CopyableCoin.create!(kind: 'cent', year: 1943)
      coin.create_copy!
      expect(CopyableCoin.where(kind: 'cent').count).to eq(2)
      expect(CopyableCoin.where(year: 1943).count).to eq(2)
    end

    it 'should update timestamp columns' do
      expect(CopyableCoin.count).to eq(0)
      coin = CopyableCoin.create!(kind: 'cent', year: 1943)
      travel_to 2.seconds.from_now do
        coin_copy = coin.create_copy!
        expect(coin_copy.updated_at).to be_present
        expect(coin_copy.created_at).to be_present
        expect(coin_copy.updated_at).not_to eq(coin.updated_at)
        expect(coin_copy.created_at).not_to eq(coin.created_at)
      end
    end
  end

  context 'when asked to do a column copy with customization' do
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
        end
      end
    end
    describe '#create_copy!' do
      it 'should create a new record with the customized column' do
        expect(CopyableCoin.count).to eq(0)
        coin = CopyableCoin.create!(kind: 'quarter', year: 1964)
        coin.create_copy!
        expect(CopyableCoin.where(kind: 'quarter').count).to eq(1)
        expect(CopyableCoin.where(kind: 'Copy of quarter').count).to eq(1)
        expect(CopyableCoin.where(year: 1964).count).to eq(2)
      end
    end
  end

  context 'when asked to do a copy that produces invalid data' do
    before(:each) do
      undefine_copyable_in CopyableCoin
      class CopyableCoin < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            kind:  :copy,
            year:  lambda { |orig| -444 },
          })
          associations({
          })
        end
      end
    end
    it 'should raise an error if data is not valid' do
      expect(CopyableCoin.count).to eq(0)
      coin = CopyableCoin.create!(kind: 'cent', year: 1982)
      expect {
        coin.create_copy!
      }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'with :do_not_copy advice' do
    before(:each) do
      undefine_copyable_in CopyableCoin
      class CopyableCoin < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            kind:  :do_not_copy,
            year:  :copy,
          })
          associations({
          })
        end
      end
    end
    it 'should result in a nil value for that column' do
      expect(CopyableCoin.count).to eq(0)
      coin = CopyableCoin.create!(kind: 'cent', year: 1982)
      copied_coin = coin.create_copy!
      expect(copied_coin.kind).to be_nil
    end
  end
end
