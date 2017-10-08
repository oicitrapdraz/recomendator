#json.array! @list2

json.array! @list2 do |place|
	json.id place['id']
	json.name place['name']
	json.icon place['icon']
	json.address place['vicinity']
	json.rating place['rating']

	json.geometry do
		json.location place['geometry']['location']
	end

	json.types do
		json.array! place['types']
	end

	json.opening_hours place['opening_hours']

	json.place_id place['place_id']
	json.reference place['reference']
	
end