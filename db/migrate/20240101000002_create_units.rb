class CreateUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :units do |t|
      t.references :property, null: false, foreign_key: true
      t.string :unit_number, null: false

      t.timestamps
    end

    # Unit numbers must be unique within a property, but two different
    # properties can each have a unit "1A"
    add_index :units, [:property_id, :unit_number], unique: true
  end
end
