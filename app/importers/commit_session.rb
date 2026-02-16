# Commits a confirmed ImportSession to the database.
#
# All inserts and updates happen inside a single transaction. If anything
# fails, the entire operation is rolled back and the ImportSession is
# marked as failed — no partial imports.
#
# Result object exposes:
#   success?      => Boolean
#   created_count => Integer
#   updated_count => Integer
#   error_message => String | nil
#   properties    => Array of Property records (created or updated)
#
# Usage:
#   result = PropertyCommitter.commit(session)
#   result.success?      # => true
#   result.created_count # => 3
class CommitSession
  Result = Struct.new(:success?, :created_count, :updated_count, :error_message, :properties,
                      keyword_init: true)

  def self.commit(session)
    new(session).commit
  end

  def initialize(session)
    @session = session
  end

  def commit
    created    = []
    updated    = []
    properties = []

    ActiveRecord::Base.transaction do
      @session.active_rows.each do |row|
        property = upsert_property(row)
        upsert_unit(property, row["unit"]) if row["unit"].present?

        if row["status"] == "new"
          created << property
        else
          updated << property
        end
        properties << property
      end

      @session.update!(status: "confirmed")
    end

    Result.new(
      success?:      true,
      created_count: created.size,
      updated_count: updated.size,
      error_message: nil,
      properties:    properties
    )
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved => e
    @session.update_columns(status: "failed", error_message: e.message)
    Result.new(
      success?:      false,
      created_count: 0,
      updated_count: 0,
      error_message: e.message,
      properties:    []
    )
  end

  private

  def upsert_property(row)
    property = Property.find_by_name_ci(row["building_name"]) ||
               Property.new(name: row["building_name"])

    property.assign_attributes(
      street_address: row["street_address"],
      city:           row["city"],
      state:          row["state"],
      zip_code:       row["zip_code"]
    )
    property.save!
    property
  end

  def upsert_unit(property, unit_number)
    unit = property.units.find_by("LOWER(unit_number) = LOWER(?)", unit_number) ||
           property.units.build(unit_number: unit_number)
    unit.save!
  end
end