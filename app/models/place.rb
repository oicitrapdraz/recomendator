class Place < ApplicationRecord
	has_and_belongs_to_many :preferences
  has_many :ratings
	has_many :users, :through => :ratings
end
