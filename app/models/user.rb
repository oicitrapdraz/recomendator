class User < ApplicationRecord
	validates :android_id, uniqueness: true
	has_and_belongs_to_many :preferences
	has_many :places, :through => :ratings
end
