require_relative 'helper/copyable_spec_helper'

describe 'failing' do
  before(:each) do

    #***************************************************************************
    #  Define all of the copyable declarations.

    undefine_copyable_in CopyableVehicle
    class CopyableVehicle < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:               :copy,
          copyable_owner_id:  :copy,
        })
        associations({
          copyable_amenities:  :copy,
        })
      end
    end

    undefine_copyable_in CopyableAmenity
    class CopyableAmenity < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:                 :copy,
          copyable_vehicle_id:  :copy,
          copyable_owner_id:    :copy,
        })
        associations({
          copyable_warranty:  :copy,
        })
      end
    end

    undefine_copyable_in CopyableWarranty
    class CopyableWarranty < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:                 lambda { |orig| raise Copyable::CopyableError.new("intentional error") },
          copyable_amenity_id:  :copy,
        })
        associations({
        })
      end
    end

    #***************************************************************************
    #  Create the models.

    @vehicle1 = CopyableVehicle.create!(name: 'Corvette')
    @amenity1 = CopyableAmenity.create!(name: 'moon roof', copyable_vehicle: @vehicle1)
    @warranty1 = CopyableWarranty.create!(name: 'moon roof warranty', copyable_amenity: @amenity1)
    @amenity2 = CopyableAmenity.create!(name: 'twitter', copyable_vehicle: @vehicle1)
    @warranty2 = CopyableWarranty.create!(name: 'twitter warranty', copyable_amenity: @amenity2)
    @amenity3 = CopyableAmenity.create!(name: 'jazz', copyable_vehicle: @vehicle1)
    @warranty3 = CopyableWarranty.create!(name: 'jazz warranty', copyable_amenity: @amenity3)
  end

  it 'should be transactional' do
    expect(CopyableVehicle.count).to eq(1)
    expect(CopyableAmenity.count).to eq(3)
    expect(CopyableWarranty.count).to eq(3)
    begin
      @vehicle2 = @vehicle1.create_copy!
    rescue Copyable::CopyableError
      # swallow the intentional error
    end
    # transaction rollback should prevent any new records from actually
    # being generated
    expect(CopyableVehicle.count).to eq(1)
    expect(CopyableAmenity.count).to eq(3)
    expect(CopyableWarranty.count).to eq(3)
  end
end
