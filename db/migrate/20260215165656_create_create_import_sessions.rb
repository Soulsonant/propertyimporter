class CreateCreateImportSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :create_import_sessions do |t|
      t.string :status
      t.jsonb :parsed_data
      t.integer :dismissed_rows
      t.string :original_filename
      t.text :error_message

      t.timestamps
    end
  end
end
