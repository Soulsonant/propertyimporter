class CreatePropertyInfos < ActiveRecord::Migration[7.2]
  def change
    create_table :property_infos do |t|
      t.string :building_name
      t.string :street_address
      t.string :city
      t.string :state
      t.string :zip_code

      t.timestamps
    end
    add_index :properties, :name, unique: true, if_not_exists: true
  end
end
