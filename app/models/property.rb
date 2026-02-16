# Represents a single building/property.
# Building name is the unique identifier used for duplicate detection during import.
class Property < ApplicationRecord
  has_many :units, dependent: :destroy

  validates :name,          presence: true, uniqueness: { case_sensitive: false }
  validates :street_address, presence: true
  validates :city,          presence: true
  validates :state,         presence: true, length: { is: 2 }
  validates :zip_code,      presence: true,
                            format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be 5-digit or ZIP+4" }

  # Case-insensitive name lookup used by the importer for duplicate detection
  def self.find_by_name_ci(name)
    where("LOWER(name) = LOWER(?)", name.to_s.strip).first
  end
end
