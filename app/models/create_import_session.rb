# parsed_data is a JSONB array of hashes, one per CSV row:
#   {
#     "row_index"      => 0,
#     "building_name"  => "Avenue Apartments",
#     "street_address" => "569 Pine Dr.",
#     "unit"           => "",
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

#i've never done anything like this before.  a lot of claude and asking questions.  