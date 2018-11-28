require_relative 'helper/copyable_spec_helper'

describe 'complex model hierarchies:' do
  before(:each) do
    undefine_copyable_in CopyableOwner
    class CopyableOwner < ActiveRecord::Base
      copyable do
        disable_all_callbacks_and_observers_except_validate
        columns({
          name:  :copy,
        })
        associations({
          copyable_vehicles:  :copy,
          copyable_amenities: :copy,
        })
      end
    end
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
          name:                 :copy,
          copyable_amenity_id:  :copy,
        })
        associations({
        })
      end
    end
  end

  describe 'a tree structure' do
    before(:each) do
      # We are avoiding using owners to avoid the denormalized aspect
      # of the data model and keep this a simple tree.
      @vehicle1 = CopyableVehicle.create!(name: 'Corvette')

      @amenity1 = CopyableAmenity.create!(name: 'moon roof', copyable_vehicle: @vehicle1)
      @warranty1 = CopyableWarranty.create!(name: 'moon roof warranty', copyable_amenity: @amenity1)
      @amenity2 = CopyableAmenity.create!(name: 'twitter', copyable_vehicle: @vehicle1)
      @warranty2 = CopyableWarranty.create!(name: 'twitter warranty', copyable_amenity: @amenity2)
      @amenity3 = CopyableAmenity.create!(name: 'jazz', copyable_vehicle: @vehicle1)
      @warranty3 = CopyableWarranty.create!(name: 'jazz warranty', copyable_amenity: @amenity3)
    end

    it 'should copy the entire tree as directed' do
      @vehicle2 = @vehicle1.create_copy!
      expect(CopyableVehicle.count).to eq(2)
      expect(CopyableAmenity.count).to eq(6)
      expect(CopyableWarranty.count).to eq(6)
      expect(@vehicle2.name).to eq('Corvette')
      expect(@vehicle2.copyable_amenities.map(&:name)).to match_array(
       ['moon roof', 'twitter', 'jazz'])
      expect(@vehicle2.copyable_amenities.map(&:copyable_warranty).map(&:name)).to match_array(
       ['moon roof warranty', 'twitter warranty', 'jazz warranty'])
    end

    it 'should skip branches of the tree when directed' do
      @vehicle2 = @vehicle1.create_copy!(skip_associations: [:copyable_amenities])
      expect(CopyableVehicle.count).to eq(2)
      expect(CopyableAmenity.count).to eq(3) # No new ones created
      expect(CopyableWarranty.count).to eq(3) # Because the amenities weren't copied either
    end

    it 'should skip nested branches of the tree when directed' do
      @vehicle2 = @vehicle1.create_copy!(skip_associations: [:copyable_warranty])
      expect(CopyableVehicle.count).to eq(2)
      expect(CopyableAmenity.count).to eq(6)
      expect(CopyableWarranty.count).to eq(3) # No new ones created
    end

    it 'should create the expected records if copied multiple times' do
      # this test makes sure the SingleCopyEnforcer isn't too eager
      @vehicle1.create_copy!
      expect(CopyableVehicle.count).to eq(2)
      expect(CopyableAmenity.count).to eq(6)
      expect(CopyableWarranty.count).to eq(6)
      @vehicle1.create_copy!
      expect(CopyableVehicle.count).to eq(3)
      expect(CopyableAmenity.count).to eq(9)
      expect(CopyableWarranty.count).to eq(9)
      @vehicle1.create_copy!
      expect(CopyableVehicle.count).to eq(4)
      expect(CopyableAmenity.count).to eq(12)
      expect(CopyableWarranty.count).to eq(12)
    end
  end

  describe 'a denormalized structure' do
    context 'having one redundant association' do
      before(:each) do
        @joe = CopyableOwner.create!(name: 'Joe')
        @porsche = CopyableVehicle.create!(name: 'Porsche', copyable_owner: @joe)
        @moon_roof = CopyableAmenity.create!(name: 'moon roof',
                                             copyable_vehicle: @porsche,
                                             copyable_owner: @joe)
      end

      it 'should copy the records without copying any given record more than once' do
        @copy_of_joe = @joe.create_copy!
        expect(CopyableOwner.count).to eq(2)
        expect(CopyableVehicle.count).to eq(2)
        expect(CopyableAmenity.count).to eq(2)
      end

      context 'with a global override, can copy vehicle with new owner' do
        before(:each) do
          @jane = CopyableOwner.create!(name: 'Jane')
        end

        it 'should copy the records correctly' do
          @copy_of_joes_car = @porsche.create_copy!(global_override: { copyable_owner_id: @jane.id })
          expect(CopyableVehicle.count).to eq(2)
          expect(CopyableAmenity.count).to eq(2)
          expect(@copy_of_joes_car.copyable_owner_id).to eq(@jane.id)
          expect(@copy_of_joes_car.copyable_amenities.first.copyable_owner_id).to eq(@jane.id)
        end
      end
    end

    context 'with many models, some having redundant associations' do
      before(:each) do
        @joe = CopyableOwner.create!(name: 'Joe')

        @porsche = CopyableVehicle.create!(name: 'Porsche', copyable_owner: @joe)
        @moon_roof = CopyableAmenity.create!(
          name: 'moon roof',
          copyable_vehicle: @porsche,
          copyable_owner: @joe)

        @mustang = CopyableVehicle.create!(name: 'Mustang', copyable_owner: @joe)
        @air_conditioning = CopyableAmenity.create!(
          name: 'air conditioning',
          copyable_vehicle: @mustang,
          copyable_owner: @joe)
        @air_conditioning_warranty = CopyableWarranty.create!(
          name: 'air conditioning warranty',
          copyable_amenity: @air_conditioning)

        @corvette = CopyableVehicle.create!(name: 'Corvette', copyable_owner: @joe)
        @pillows = CopyableAmenity.create!(
          name: 'pillows',
          copyable_vehicle: @corvette,
          copyable_owner: @joe)
        @pillow_warranty = CopyableWarranty.create!(name: 'pillow warranty', copyable_amenity: @pillows)
        @airbags = CopyableAmenity.create!(
          name: 'airbags',
          copyable_vehicle: @corvette,
          copyable_owner: @joe)
        @airbag_warranty = CopyableWarranty.create!(name: 'airbag warranty', copyable_amenity: @airbags)
        @radio = CopyableAmenity.create!(
          name: 'satellite radio',
          copyable_vehicle: @corvette,
          copyable_owner: @joe)
      end

      it 'should copy the records without copying any given record more than once' do
        @copy_of_joe = @joe.create_copy!
        expect(CopyableOwner.count).to eq(2)
        expect(CopyableVehicle.count).to eq(6)
        expect(CopyableAmenity.count).to eq(10)
        expect(CopyableWarranty.count).to eq(6)
        expect(@copy_of_joe.copyable_vehicles.map(&:name)).to match_array([
          'Porsche', 'Mustang', 'Corvette'])
        expect(@copy_of_joe.copyable_amenities.map(&:name)).to match_array([
          'moon roof', 'air conditioning', 'pillows', 'airbags', 'satellite radio'])
      end
    end
  end
end
