class CreateCreateUnits < ActiveRecord::Migration[7.2]
  def change
    create_table :create_units do |t|
      t.string :unit_number
      t.references :property, null: false, foreign_key: true

      t.timestamps
    end
  end
end
