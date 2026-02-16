# Holds the state of an in-progress CSV import.
#
# Lifecycle:
#   pending   -> user has uploaded and is reviewing the preview
#   confirmed -> user clicked Confirm; records committed to DB
#   failed    -> commit was attempted but the transaction was rolled back
#
# parsed_data is a JSONB array of hashes, one per CSV row:
#   {
#     "row_index"      => 0,
#     "building_name"  => "Riverside Tower",
#     "street_address" => "123 Main St",
#     "unit"           => "101",
#     "city"           => "Cincinnati",
#     "state"          => "OH",
#     "zip_code"       => "45202",
#     "errors"         => [],          # validation error strings
#     "status"         => "new"        # new | existing | error | duplicate
#   }
class ImportSession < ApplicationRecord
  STATUSES = %w[pending confirmed failed].freeze

  validates :status, inclusion: { in: STATUSES }

  # Rows the user has not dismissed
  def active_rows
    parsed_data.reject { |row| dismissed_rows.include?(row["row_index"]) }
  end

  # Rows with validation errors that have not been dismissed
  def blocking_rows
    active_rows.select { |row| row["status"] == "error" || row["status"] == "duplicate" }
  end

  # Whether the import is ready to be committed
  def confirmable?
    status == "pending" && blocking_rows.empty? && active_rows.any?
  end

  def pending?   = status == "pending"
  def confirmed? = status == "confirmed"
  def failed?    = status == "failed"

  # Counts for the summary banner
  def total_count     = parsed_data.size
  def dismissed_count = dismissed_rows.size
  def active_count    = active_rows.size
  def error_count     = active_rows.count { |r| %w[error duplicate].include?(r["status"]) }
  def new_count       = active_rows.count { |r| r["status"] == "new" }
  def existing_count  = active_rows.count { |r| r["status"] == "existing" }
end
