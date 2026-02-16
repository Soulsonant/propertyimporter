class CreateImportSessions < ActiveRecord::Migration[7.2]
  def change
    create_table :import_sessions do |t|
      # pending: parsed, awaiting user review
      # confirmed: committed to the database
      # failed: commit attempted but rolled back
      t.string :status, null: false, default: "pending"

      # Full structured data parsed from the CSV, stored as JSONB so we
      # avoid a separate staging table and can query row-level data during preview
      t.jsonb :parsed_data, null: false, default: []

      # Row indices the user has explicitly dismissed from the import
      t.integer :dismissed_rows, array: true, null: false, default: []

      t.string :original_filename
      t.text :error_message

      t.timestamps
    end

    add_index :import_sessions, :status
  end
end
