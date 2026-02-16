class PropertyInfo < ApplicationRecord
  validates :building_name,     presence: true, uniqueness: { case_sensitive: false}
  validates :street_address,    presence: true
  validates :city,              presence: true
  validates :state,             presence: true
  validates :zip_code,          presence: true, format: { with: /\A\d{5}(-\d{4})?\z/, message: "must be 5-digit or ZIP+4" }

    #  duplicate detection
  def self.find_by_name_ci(name)
    where("LOWER(building_name) = LOWER(?)", name.to_s.strip).first
  end
end

#fairly big change to original idea using a session import.  
#duplicate detection on name.  not sure how to parse state.  require 2 letter state abbr in future for sanity checks?


