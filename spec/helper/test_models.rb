# We need various test models in various configurations to properly test the
# copying functionality.


#*******************************************************************************
#  For testing basic copying behavior and validation.
#

class CopyableCoin < ActiveRecord::Base
  validates :year, numericality: { greater_than: 1700 }
end



#*******************************************************************************
#  For testing observers.
#

class CopyableCar < ActiveRecord::Base
  validates :make, presence: true
  validates :model, presence: true
  validates :year, presence: true
end



#*******************************************************************************
#  For testing callbacks.
#

class CopyableTree < ActiveRecord::Base
  after_create  :callback1
  before_save   { |tree| raise "callback2 called" }
  def callback1
    raise "callback1 called"
  end
end



#*******************************************************************************
#  For testing basic associations.
#

class CopyablePet < ActiveRecord::Base
  has_many :copyable_toys
  has_one :copyable_pet_tag
  has_one :copyable_pet_profile
  has_one :copyable_address, through: :copyable_pet_profile
  # Rails 3 expects the join table to be called copyable_pet_foods_copyable_pets
  # Rails 4 expects the join table to be called copyable_pet_foods_pets
  # We explicitly name the join table so that this code works with both Rails 3 and Rails 4.
  has_and_belongs_to_many :copyable_pet_foods, join_table: 'copyable_pet_foods_pets'
  has_many :copyable_pet_sitting_patronages
  has_many :copyable_pet_sitters, through: :copyable_pet_sitting_patronages
end

class CopyableToy < ActiveRecord::Base
  validates  :name, length: { minimum: 3 }
  belongs_to :copyable_pet
end

class CopyablePetTag < ActiveRecord::Base
  belongs_to :copyable_pet
end

class CopyablePetFood < ActiveRecord::Base
  # Rails 3 expects the join table to be called copyable_pet_foods_copyable_pets
  # Rails 4 expects the join table to be called copyable_pet_foods_pets
  # We explicitly name the join table so that this code works with both Rails 3 and Rails 4.
  has_and_belongs_to_many :copyable_pets, join_table: 'copyable_pet_foods_pets'
end

class CopyablePetSitter < ActiveRecord::Base
  has_many :copyable_pet_sitting_patronages
  has_many :copyable_pets, through: :copyable_pet_sitting_patronages
end

class CopyablePetSittingPatronage < ActiveRecord::Base
  belongs_to :copyable_pet
  belongs_to :copyable_pet_sitter
end

class CopyablePetProfile < ActiveRecord::Base
  belongs_to :copyable_pet
  has_one :copyable_address
end

class CopyableAddress < ActiveRecord::Base
  belongs_to :copyable_pet_profile
end



#*******************************************************************************
#  For testing polymorphic associations and custom-named foreign keys.
#

class CopyablePicture < ActiveRecord::Base
  belongs_to :imageable, polymorphic: true
  belongs_to :copyable_album, foreign_key: 'picture_album_id'
end

class CopyableProduct < ActiveRecord::Base
  has_many :copyable_pictures, as: :imageable
end

class CopyableAlbum < ActiveRecord::Base
  has_many :copyable_pictures, foreign_key: 'picture_album_id'
end



#*******************************************************************************
#  For testing denormalized data structures.
#

class CopyableOwner < ActiveRecord::Base
  has_many :copyable_vehicles
  has_many :copyable_amenities  # this is not normalized, you wouldn't normally do this
end

class CopyableVehicle < ActiveRecord::Base
  has_many :copyable_amenities
  belongs_to  :copyable_owner
end

class CopyableAmenity < ActiveRecord::Base
  belongs_to :copyable_vehicle
  belongs_to :copyable_owner  # this is not normalized, you wouldn't normally do this
  has_one :copyable_warranty
end

class CopyableWarranty < ActiveRecord::Base
  belongs_to :copyable_amenity
end
