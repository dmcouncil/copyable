require_relative 'helper/copyable_spec_helper'

describe 'create_copy!' do
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

  it 'should exist' do
    coin = CopyableCoin.create!(kind: 'cent', year: 1909)
    expect(coin).to respond_to(:create_copy!)
  end

  it 'should create a new record' do
    expect(CopyableCoin.count).to eq(0)
    coin = CopyableCoin.create!(kind: 'cent', year: 1909)
    coin.create_copy!
    expect(CopyableCoin.count).to eq(2)
  end

  it 'should return the new record' do
    expect(CopyableCoin.count).to eq(0)
    coin = CopyableCoin.create!(kind: 'cent', year: 1909)
    coin2 = coin.create_copy!
    expect(coin2).to be_a CopyableCoin
  end

  it 'should return the new record having an id' do
    expect(CopyableCoin.count).to eq(0)
    coin = CopyableCoin.create!(kind: 'cent', year: 1909)
    coin2 = coin.create_copy!
    expect(coin2.id).not_to be_nil
  end

  it 'should allow columns to be overridden' do
    expect(CopyableCoin.count).to eq(0)
    coin = CopyableCoin.create!(kind: 'cent', year: 1909)
    coin2 = coin.create_copy!(override: { year: 1959 })
    expect(coin2.kind).to eq('cent')
    expect(coin2.year).to eq(1959)
  end

  it 'should allow columns to be overridden using strings as column names' do
    expect(CopyableCoin.count).to eq(0)
    coin = CopyableCoin.create!('kind' => 'cent', 'year' => 1909)
    coin2 = coin.create_copy!(override: { 'year' => 1959 })
    expect(coin2.kind).to eq('cent')
    expect(coin2.year).to eq(1959)
  end

  it 'should allow validations to be skipped' do
    coin = CopyableCoin.create!('kind' => 'cent', 'year' => 1909)
    expect {
      coin.create_copy!(override: { 'year' => 2 })
    }.to raise_error(ActiveRecord::RecordInvalid)
    expect {
      coin.create_copy!(override: { 'year' => 2 }, skip_validations: true)
    }.to_not raise_error
  end

  it 'should skip validations even in associated objects when skip_validations is true' do
    # set up classes
    undefine_copyable_in CopyablePet
    class CopyablePet < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:        :copy,
          kind:        :copy,
          birth_year:  :copy,
        })
        associations({
          copyable_toys:                    :copy,
          copyable_pet_tag:                 :do_not_copy,
          copyable_pet_profile:             :do_not_copy,
          copyable_pet_foods:               :do_not_copy,
          copyable_pet_sitting_patronages:  :do_not_copy,
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

    # set up objects
    fido = CopyablePet.create!(
     name: 'Fido',
     kind: 'canine',
     birth_year: 2005)

    pillow = CopyableToy.create!(
     name: 'favorite pillow',
     kind: 'soft',
     copyable_pet: fido)

    # everything should be wonderful
    expect {
      fido.create_copy!
    }.to_not raise_error

    # now inject some invalid data in an associated object
    pillow.update_column(:name, 'o')
    fido.reload

    # fail because invalid!
    expect {
      fido.create_copy!
    }.to raise_error(ActiveRecord::RecordInvalid)

    # oh quit complaning and do it anyway!
    expect {
      fido.create_copy!(skip_validations: true)
    }.to_not raise_error
  end
end
