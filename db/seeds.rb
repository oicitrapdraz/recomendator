key = "TPSW_servidor"

User.create([{name: "Ricardo", password: AESCrypt.encrypt("hola123", key), android_id: "5fg8", email: "ricardo@gmail.com"}, {name: "Ruben",password: AESCrypt.encrypt("hola1234", key) ,android_id: "5fg7", email: "ruben@gmail.com"}])

Preference.create([{ type_of_place: "point_of_interest" }, { type_of_place: "museum" }, { type_of_place: "movie_theater" }, { type_of_place: "zoo" }])

Place.create([{google_id: "c62ff936021b742f50eceb6df0ca7afdebb1ac60", name: "RecreoTV", vicinity: "Hortensias 20, Viña del Mar, Recreo, Viña del Mar, Chile", icon: "https://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png", location: "-33.0291217, -71.57537289999999"}, {google_id: "72906f18aa0c73f5c77cebc0d9de9ea052435988", name: "Mirador La Puntilla", vicinity: "Juan Elkins 116, Valparaíso, Valparaíso", icon: "https://maps.gstatic.com/mapfiles/place_api/icons/museum-71.png", location: " -33.03601430000001, -71.5977814"}])

User.find(1).preferences << Preference.find(1) unless User.find(1).preferences.include?(Preference.find(1))
User.find(1).preferences << Preference.find(2) unless User.find(1).preferences.include?(Preference.find(2))

User.find(2).preferences << Preference.find(1) unless User.find(2).preferences.include?(Preference.find(1))
User.find(2).preferences << Preference.find(2) unless User.find(2).preferences.include?(Preference.find(2))
User.find(2).preferences << Preference.find(3) unless User.find(2).preferences.include?(Preference.find(3))

Place.find(1).preferences << Preference.find(1)
Place.find(1).preferences << Preference.find(2)

Place.find(2).preferences << Preference.find(1)
Place.find(2).preferences << Preference.find(2)

Rating.create([{user_id: 1, place_id: 1, rating: 4}, {user_id: 2, place_id: 1, rating: 3},{user_id: 2, place_id: 2, rating: 100}])