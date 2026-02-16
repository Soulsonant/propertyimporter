class Proptertyimp < ApplicationRecord
  validates :building_name,     presence: true
  validates :street_address,    presence: true
  validates :unit,              presence: true
  validates :city,              presence: true
  validates :state,             presence: true
  validates :zip_code,          presence: true
end

#currently I want everything