@obj['results'].each do |key,value|
  json.results key['geometry']
  json.tags key['types']
end


#json.array! @obj, partial: 'location/obj', as: :obj