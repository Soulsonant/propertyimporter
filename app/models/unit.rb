# Belongs to a Property. Unit number must be unique within a property
# but can be reused across different properties.
class Unit < ApplicationRecord
  belongs_to :property

  validates :unit_number, presence: true,
                          format: {
                            with: /\A[a-zA-Z0-9\-]+\z/,
                            message: "only allows letters, numbers, and hyphens"
                          },
                          uniqueness: { scope: :property_id, case_sensitive: false }
end
