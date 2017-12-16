class Rating < ApplicationRecord
  belongs_to :user
  belongs_to :place
  validates_uniqueness_of :place_id, :scope => :user_id
end