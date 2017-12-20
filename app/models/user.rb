require 'mathn'

class User < ApplicationRecord
	validates :android_id, uniqueness: true
	has_and_belongs_to_many :preferences
  has_many :ratings
	has_many :places, :through => :ratings

  def get_place_recommendations
    # sacar ratings del usuario
    ratings = self.ratings
    rating_place_ids = ratings.map(&:place_id)

    # obtener el usuario más similar
    most_similar_user = User.where("id != ?", self.id).max_by do |user2|
      u2_ratings = user2.ratings.where(place_id: rating_place_ids)
      v2 = Vector[*u2_ratings.map(&:rating)]
      v1 = Vector[*ratings.where(place_id: u2_ratings.map(&:place_id)).map(&:rating)] # get subset
      p v1, v2

      #v1.size == 0 ? Float::INFINITY : (v1-v2).norm # mean squared error
      v1.size == 0 ? 0 : Math.cos(v1.angle_with(v2)) # cosine distance
    end
    most_similar_user.ratings.\
      where("place_id NOT IN (?)", rating_place_ids).\
      map {|x| {"name": x.place.name,
                "place_id": x.place.google_id,
                "rating": x.rating}}
  end

end
