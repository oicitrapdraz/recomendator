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

    # obtener el usuario más similar según distancia coseno
    v = Vector[*ratings.map {|x| 3 - x.rating }]
    most_similar_user = User.where("id != ?", self.id).max_by do |user2|
      v2 = Vector[*user2.ratings.where(place_id: rating_place_ids).map {|x| 3-x.rating }]
      Math.cos(v.angle_with(v2))
    end
    most_similar_user.ratings.\
      where("place_id NOT IN (?)", rating_place_ids).\
      map {|x| {"name": x.place.name,
                "place_id": x.place.google_id,
                "rating": x.rating}}
  end

end
