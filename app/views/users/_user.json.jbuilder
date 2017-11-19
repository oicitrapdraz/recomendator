json.user do 
	json.id user.id
	json.username user.name
	json.password user.password
	json.email user.email
	json.preferences do
		json.array! user.preferences do |preference|
			json.id preference.id
			json.type_of_place preference.type_of_place
		end
	end
end
json.url user_url user