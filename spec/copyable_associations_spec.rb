require_relative 'helper/copyable_spec_helper'

describe 'copyable:associations' do

  context 'copying a has many relationship' do
    before(:each) do
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
    end
    it 'should produce copies of the associated records' do
      pet1 = CopyablePet.create!(name: 'Pet1', kind: 'cat', birth_year: 2010)
      pet2 = CopyablePet.create!(name: 'Pet2', kind: 'cat', birth_year: 2011)
      pet3 = CopyablePet.create!(name: 'Pet3', kind: 'cat', birth_year: 2012)
      sitter1 = CopyablePetSitter.create!(name: 'Sitter1')
      sitter2 = CopyablePetSitter.create!(name: 'Sitter2')
      sitter3 = CopyablePetSitter.create!(name: 'Sitter3')
      sitter4 = CopyablePetSitter.create!(name: 'Sitter4')
      patronage1 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet1.id,
       copyable_pet_sitter_id: sitter2.id)
      patronage2 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet2.id,
       copyable_pet_sitter_id: sitter2.id)
      patronage3 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet3.id,
       copyable_pet_sitter_id: sitter4.id)
      sitter2.reload
      expect(sitter2.copyable_pet_sitting_patronages.size).to eq(2)
      copied_sitter = sitter2.create_copy!
      expect(copied_sitter.copyable_pet_sitting_patronages.size).to eq(2)
      expect(copied_sitter.copyable_pets.map(&:name)).to match_array(['Pet1', 'Pet2'])
    end
  end

  context 'do not copy' do
    before(:each) do
      undefine_copyable_in CopyablePetSitter
      class CopyablePetSitter < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            name:  :copy,
          })
          associations({
            copyable_pet_sitting_patronages:  :do_not_copy,
          })
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
    end
    it 'should not produce copies of the associated records' do
      pet1 = CopyablePet.create!(name: 'Pet1', kind: 'cat', birth_year: 2010)
      pet2 = CopyablePet.create!(name: 'Pet2', kind: 'cat', birth_year: 2011)
      pet3 = CopyablePet.create!(name: 'Pet3', kind: 'cat', birth_year: 2012)
      sitter1 = CopyablePetSitter.create!(name: 'Sitter1')
      sitter2 = CopyablePetSitter.create!(name: 'Sitter2')
      sitter3 = CopyablePetSitter.create!(name: 'Sitter3')
      sitter4 = CopyablePetSitter.create!(name: 'Sitter4')
      patronage1 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet1.id,
       copyable_pet_sitter_id: sitter2.id)
      patronage2 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet2.id,
       copyable_pet_sitter_id: sitter2.id)
      patronage3 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet3.id,
       copyable_pet_sitter_id: sitter4.id)
      sitter2.reload
      expect(sitter2.copyable_pet_sitting_patronages.size).to eq(2)
      expect(CopyablePetSittingPatronage.count).to eq(3)
      copied_sitter = sitter2.create_copy!
      expect(copied_sitter.copyable_pet_sitting_patronages.size).to eq(0)
      expect(CopyablePetSittingPatronage.count).to eq(3)
    end
  end

  context 'copying a has one relationship' do
    before(:each) do
      undefine_copyable_in CopyablePetProfile
      class CopyablePetProfile < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            description:      :copy,
            nickname:         :copy,
            copyable_pet_id:  lambda { |orig| 177777 }, # random bogus CopyablePet id since we don't need a real CopyablePet record for this test
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
    end

    it 'should produce a copy of the associated record' do
      profile1 = CopyablePetProfile.create!(description: 'Prof1',
                                            copyable_pet_id: 177777)
      profile2 = CopyablePetProfile.create!(description: 'Prof2',
                                            copyable_pet_id: 188888)
      profile3 = CopyablePetProfile.create!(description: 'Prof3',
                                            copyable_pet_id: 199999)
      address1 = CopyableAddress.create!(address1: 'Add1',
                                         city: 'Cambridge',
                                         state: 'MA',
                                         copyable_pet_profile_id: profile1.id)
      address2 = CopyableAddress.create!(address1: 'Add2',
                                         city: 'Boston',
                                         state: 'MA',
                                         copyable_pet_profile_id: profile2.id)
      address3 = CopyableAddress.create!(address1: 'Add3',
                                         city: 'Somerville',
                                         state: 'MA',
                                         copyable_pet_profile_id: profile3.id)
      expect(CopyablePetProfile.count).to eq(3)
      expect(CopyableAddress.count).to eq(3)
      copied_profile = profile1.create_copy!
      expect(CopyablePetProfile.count).to eq(4)
      expect(CopyableAddress.count).to eq(4)
      expect(copied_profile.copyable_address.address1).to eq('Add1')
      expect(copied_profile.copyable_address.city).to eq('Cambridge')
    end

    it 'should not copy the associated record if it is nil' do
      profile1 = CopyablePetProfile.create!(description: 'Prof1',
                                            copyable_pet_id: 56565656)  # bogus id
      expect(CopyablePetProfile.count).to eq(1)
      expect(CopyableAddress.count).to eq(0)
      copied_profile = profile1.create_copy!
      expect(CopyablePetProfile.count).to eq(2)
      expect(CopyableAddress.count).to eq(0)
      expect(copied_profile.copyable_address).to be_nil
    end
  end

  context 'copying a has and belongs to many relationship' do
    before(:each) do
      undefine_copyable_in CopyablePetFood
      class CopyablePetFood < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            name:        :copy,
          })
          associations({
            copyable_pets:  :copy_only_habtm_join_records,
          })
        end
      end
    end
    it 'should produce a copy of the associations but not the records' do
      pet1 = CopyablePet.create!(name: 'Pet1', kind: 'cat', birth_year: 2010)
      pet2 = CopyablePet.create!(name: 'Pet2', kind: 'cat', birth_year: 2011)
      pet3 = CopyablePet.create!(name: 'Pet3', kind: 'cat', birth_year: 2012)
      food1 = CopyablePetFood.create!(name: 'Food1')
      food2 = CopyablePetFood.create!(name: 'Food2')
      food3 = CopyablePetFood.create!(name: 'Food3')
      food4 = CopyablePetFood.create!(name: 'Food4')
      food1.copyable_pets << pet1
      food1.copyable_pets << pet2
      food3.copyable_pets << pet3
      copied_food1 = food1.create_copy!
      copied_food2 = food2.create_copy!
      copied_food3 = food3.create_copy!
      expect(copied_food1.copyable_pets.map(&:name)).to match_array(['Pet1', 'Pet2'])
      expect(copied_food2.copyable_pets.map(&:name)).to match_array([])
      expect(copied_food3.copyable_pets.map(&:name)).to match_array(['Pet3'])
      expect(pet1.copyable_pet_foods.size).to eq(2)
      expect(CopyablePet.count).to eq(3)
    end
  end

  context 'copying a polymorphic has many' do
    before(:each) do
      undefine_copyable_in CopyableProduct
      class CopyableProduct < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            name:  :copy,
          })
          associations({
            copyable_pictures:  :copy,
          })
        end
      end
      undefine_copyable_in CopyablePicture
      class CopyablePicture < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            name:              :copy,
            imageable_id:      :copy,
            imageable_type:    :copy,
            picture_album_id:  :copy,
          })
          associations({
          })
        end
      end
    end
    it 'should produce a copy of the associations' do
      product1 = CopyableProduct.create!(name: 'camera')
      picture1 = CopyablePicture.create!(name: 'photo1')
      picture2 = CopyablePicture.create!(name: 'photo2')
      product1.copyable_pictures << picture1
      product1.copyable_pictures << picture2
      expect(CopyableProduct.count).to eq(1)
      expect(CopyablePicture.count).to eq(2)
      copied_product = product1.create_copy!
      expect(CopyableProduct.count).to eq(2)
      expect(CopyablePicture.count).to eq(4)
      expect(copied_product.copyable_pictures.size).to eq(2)
      expect(copied_product.copyable_pictures.map(&:id)).not_to match_array(product1.copyable_pictures.map(&:id))
    end
  end

  context 'with a custom foreign key' do
    before(:each) do
      undefine_copyable_in CopyablePicture
      class CopyablePicture < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            name:              :copy,
            imageable_id:      :copy,
            imageable_type:    :copy,
            picture_album_id:  :copy,
          })
          associations({
          })
        end
      end
      undefine_copyable_in CopyableAlbum
      class CopyableAlbum < ActiveRecord::Base
        copyable do
          disable_all_callbacks_and_observers_except_validate
          columns({
            name:  :copy,
          })
          associations({
            copyable_pictures:  :copy,
          })
        end
      end
    end

    it 'should produce copies of the associated records without an error' do
      album = CopyableAlbum.create!(name: 'an album')
      picture1 = CopyablePicture.create!(name: 'photo1')
      picture2 = CopyablePicture.create!(name: 'photo2', copyable_album: album)
      picture3 = CopyablePicture.create!(name: 'photo3', copyable_album: album)
      expect(CopyableAlbum.count).to eq(1)
      expect(CopyablePicture.count).to eq(3)
      copied_album = album.create_copy!
      expect(CopyableAlbum.count).to eq(2)
      expect(CopyablePicture.count).to eq(5)
      expect(copied_album.copyable_pictures.map(&:name)).to match_array(['photo2', 'photo3'])
    end

    it 'should update polymorphic belongs_to associations correctly' do
      # This tests how the update_other_belongs_to_associations method handles
      # polymorphic assocations.  Even though the steps of this example may be
      # similar (or exactly the same) as another example, the behavior that this
      # example describes is different and is a significant part of the
      # correctness of the software.
      album = CopyableAlbum.create!(name: 'an album')
      picture1 = CopyablePicture.create!(name: 'photo1')
      picture2 = CopyablePicture.create!(name: 'photo2', copyable_album: album)
      picture3 = CopyablePicture.create!(name: 'photo3', copyable_album: album)
      expect(CopyableAlbum.count).to eq(1)
      expect(CopyablePicture.count).to eq(3)
      copied_album = album.create_copy!
      expect(CopyableAlbum.count).to eq(2)
      expect(CopyablePicture.count).to eq(5)
      expect(copied_album.copyable_pictures.map(&:name)).to match_array(['photo2', 'photo3'])
    end
  end

  context 'copying a has many relationship with a missing copyable declaration' do
    before(:each) do
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
        end
      end
      undefine_copyable_in CopyablePetSittingPatronage
      class CopyablePetSittingPatronage < ActiveRecord::Base
        undef create_copy!
        # MISSING copyable do
        #   disable_all_callbacks_and_observers_except_validate
        #   columns({
        #     copyable_pet_id:        :copy,
        #     copyable_pet_sitter_id: :copy,
        #   })
        #   associations({
        #   })
        # end
      end
    end
    it 'should raise an informative error' do
      pet1 = CopyablePet.create!(name: 'Pet1', kind: 'cat', birth_year: 2010)
      sitter1 = CopyablePetSitter.create!(name: 'Sitter1')
      patronage1 = CopyablePetSittingPatronage.create!(
       copyable_pet_id: pet1.id,
       copyable_pet_sitter_id: sitter1.id)
      expect {
        sitter1.create_copy!
      }.to raise_error(Copyable::CopyableError)
    end
  end
end
