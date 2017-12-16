Rails.application.routes.draw do
  resources :users
  
	match '/get_location' => 'location#search', via: :post
	match '/get_locations' => 'location#recommendation', via: :post
	match '/get_recommendation' => 'location#recommendation_by_preferences', via: :post
	match '/recommendations/:id' => 'location#recommendation_by_collaborative_filtering', via: :get
	match '/ratings' => 'location#rating_place', via: :post

  post 'users/login'
end
