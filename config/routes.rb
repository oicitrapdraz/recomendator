Rails.application.routes.draw do
	match '/get_location' => 'location#search', via: :post
	match '/get_locations' => 'location#recommendation', via: :post
	match '/get_recommendation' => 'location#recommendation_by_preferences', via: :post

  post 'location/search'
  post 'location/recommendation'
  post 'location/recommendation_by_preferences'
end
