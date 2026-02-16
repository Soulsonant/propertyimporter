# Takes raw parsed rows from CsvParser and annotates each one with a status
# based on duplicate detection rules. Creates and persists an ImportSession.
#
# Row statuses:
#   new       - building_name does not exist in the database; will be created
#   existing  - building_name matches a DB record; address fields will be updated
#   error     - row failed model validation (missing required field, bad ZIP, etc.)
#   duplicate - building_name appears more than once within this CSV upload
#
# Usage:
#   session = ImportSessionBuilder.build(rows: parsed_rows, filename: "upload.csv")
#   # => ImportSession (persisted)
class ImportSessionBuilder
  def self.build(rows:, filename:)
    new(rows: rows, filename: filename).build
  end

  def initialize(rows:, filename:)
    @rows     = rows
    @filename = filename
  end

  def build
    annotated = annotate_rows(@rows)
    ImportSession.create!(
      status:            "pending",
      parsed_data:       annotated,
      dismissed_rows:    [],
      original_filename: @filename
    )
  end

  private

  def annotate_rows(rows)
    # Track names seen within this upload to catch intra-CSV duplicates
    seen_names = {}

    rows.map do |row|
      name = row["building_name"].to_s.downcase.strip

      if row["csv_errors"].any?
        row.merge("status" => "error", "errors" => row["csv_errors"])

      elsif seen_names.key?(name)
        row.merge(
          "status" => "duplicate",
          "errors" => ["Building name \"#{row["building_name"]}\" appears more than once in this CSV"]
        )

      else
        seen_names[name] = true
        existing = Property.find_by_name_ci(row["building_name"])

        if existing
          diff = compute_diff(existing, row)
          row.merge(
            "status"      => "existing",
            "property_id" => existing.id,
            "diff"        => diff,
            "errors"      => []
          )
        else
          # Validate against the Property model without saving
          candidate = Property.new(
            name:           row["building_name"],
            street_address: row["street_address"],
            city:           row["city"],
            state:          row["state"],
            zip_code:       row["zip_code"]
          )
          if candidate.valid?
            row.merge("status" => "new", "errors" => [])
          else
            row.merge("status" => "error", "errors" => candidate.errors.full_messages)
          end
        end
      end
    end
  end

  # Returns a hash of { field => { "was" => old_value, "will_be" => new_value } }
  # for fields that would change on an existing property
  def compute_diff(existing, row)
    fields = { "street_address" => :street_address, "city" => :city,
               "state" => :state, "zip_code" => :zip_code }
    fields.each_with_object({}) do |(csv_key, attr), diff|
      old_val = existing.send(attr).to_s
      new_val = row[csv_key].to_s
      diff[csv_key] = { "was" => old_val, "will_be" => new_val } unless old_val == new_val
    end
  end
end
