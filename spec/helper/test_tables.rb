module Copyable
  class TestTables

    def self.create!
      return if @already_created_tables
      ActiveRecord::Migration.class_eval do
        suppress_messages do

          # All tables are prefaced with "copyable_" to avoid name collisions
          # with other tables in the test database.

          create_table :copyable_albums, force: true do |t|
            t.string :name, null: false
            t.timestamps null: false
          end

          create_table :copyable_amenities, force: true do |t|
            t.string   :name
            t.integer  :copyable_vehicle_id
            t.integer  :copyable_owner_id
            t.timestamps null: false
          end

          create_table :copyable_addresses, force: true do |t|
            t.string   :address1,                 null: false
            t.string   :address2
            t.string   :city,                     null: false
            t.string   :state,                    null: false
            t.integer  :copyable_pet_profile_id,  null: false
            t.timestamps null: false
          end

          create_table :copyable_cars, force: true do |t|
            t.string   :make,   null: false
            t.string   :model,  null: false
            t.integer  :year,   null: false
            t.timestamps null: false
          end

          create_table :copyable_coins, force: true do |t|
            t.string  :kind
            t.integer :year
            t.timestamps null: false
          end

          create_table :copyable_owners, force: true do |t|
            t.string :name, null: false
            t.timestamps null: false
          end

          create_table :copyable_pet_foods, force: true do |t|
            t.string :name, null: false
            t.timestamps null: false
          end

          create_table :copyable_pet_foods_pets, force: true, id: false do |t|
            t.integer :copyable_pet_id,      null: false
            t.integer :copyable_pet_food_id, null: false
          end

          create_table :copyable_pet_profiles, force: true do |t|
            t.string   :description,     null: false
            t.string   :nickname
            t.integer  :copyable_pet_id, null: false
            t.timestamps null: false
          end

          create_table :copyable_pet_sitters, force: true do |t|
            t.string  :name, null: false
            t.timestamps null: false
          end

          create_table :copyable_pet_sitting_patronages, force: true do |t|
            t.integer  :copyable_pet_id,        null: false
            t.integer  :copyable_pet_sitter_id, null: false
            t.timestamps null: false
          end

          create_table :copyable_pet_tags, force: true do |t|
            t.string   :registered_name, null: false
            t.integer  :copyable_pet_id, null: false
            t.timestamps null: false
          end

          create_table :copyable_pets, force: true do |t|
            t.string  :name,        null: false
            t.string  :kind,        null: false
            t.integer :birth_year
            t.timestamps null: false
          end

          create_table :copyable_pictures, force: true do |t|
            t.string  :name
            t.integer :imageable_id
            t.string  :imageable_type
            t.integer :picture_album_id
            t.timestamps null: false
          end

          create_table :copyable_products, force: true do |t|
            t.string  :name
            t.timestamps null: false
          end

          create_table :copyable_toys, force: true do |t|
            t.string   :name
            t.string   :kind
            t.integer  :copyable_pet_id
            t.timestamps null: false
          end

          create_table :copyable_trees, force: true do |t|
            t.string  :kind
            t.timestamps null: false
          end

          create_table :copyable_vehicles, force: true do |t|
            t.string  :name
            t.integer :copyable_owner_id
            t.timestamps null: false
          end

          create_table :copyable_warranties, force: true do |t|
            t.string   :name
            t.integer  :copyable_amenity_id
            t.timestamps null: false
          end

        end
      end
      @already_created_tables = true
    end

  end
end
