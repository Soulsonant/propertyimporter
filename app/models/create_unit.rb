class CreateUnit < ApplicationRecord
  belongs_to :property

  #allowing blanks is problematic.  thought about parsing numbers even more but seems restrictive atm for test.
  #need more info on property management in general wrt units.  unit numbers can be a lot of things based on research...
  validates :unit_number, presence: true, allow_blank: true
end
