key = "TPSW_servidor"

User.create([{name: "Ricardo", password: AESCrypt.encrypt("hola1234", key), android_id: "5fg8", email: "ricardo@gmail.com"},
	           {name: "Ruben", password: AESCrypt.encrypt("hola1234", key), android_id: "5fg7", email: "ruben@gmail.com"},
	           {name: "Patricio", password: AESCrypt.encrypt("hola1234", key), android_id: "5fg9", email: "patricio@gmail.com"},
	           {name: "Rodrigo", password: AESCrypt.encrypt("hola1234", key), android_id: "5fg10", email: "rorro@gmail.com"}])

Preference.create([{ type_of_place: "point_of_interest" },
                   { type_of_place: "museum" },
                   { type_of_place: "movie_theater" }, 
                   { type_of_place: "zoo" }])

Place.create([{google_id: "c62ff936021b742f50eceb6df0ca7afdebb1ac60", name: "RecreoTV", vicinity: "Hortensias 20, Viña del Mar, Recreo, Viña del Mar, Chile", icon: "https://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png", location: "-33.0291217, -71.57537289999999"},
              {google_id: "72906f18aa0c73f5c77cebc0d9de9ea052435988", name: "Mirador La Puntilla", vicinity: "Juan Elkins 116, Valparaíso, Valparaíso", icon: "https://maps.gstatic.com/mapfiles/place_api/icons/museum-71.png", location: "-33.03601430000001, -71.5977814"},
              {google_id: "c2f6db63ba700a8d000b8c49c185ce5d495dad0c", name: "Teatro Municipal de Quilpué Juan Bustos Ramírez", vicinity: "Aníbal Pinto, Quilpué, Quilpué", icon: "https://maps.gstatic.com/mapfiles/place_api/icons/movies-71.png", location: "-33.04585589999999, -71.5977814"},
              {google_id: "18f603ce0fe0e007eee5d20376e41605178634ff", name: "Quilpué Zoo", vicinity: "fundo el, Carmen, Quilpué", icon: "https://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png", location: "-33.0413888, -71.45164489999999"}])

Place.find(1).preferences << Preference.find(1)		# RecreoTV es point_of_interest 
Place.find(1).preferences << Preference.find(2)		# RecreoTV es museum

Place.find(2).preferences << Preference.find(1)		# Mirado La Puntilla es point_of_interest 
Place.find(2).preferences << Preference.find(2)		# RecreoTV es museum

Place.find(3).preferences << Preference.find(1)		# Teatro Municipal de Quilpué Juan Bustos Ramírez es point_of_interest 
Place.find(3).preferences << Preference.find(3)		# Teatro Municipal de Quilpué Juan Bustos Ramírez es movie_theater

Place.find(4).preferences << Preference.find(1)		# Quilpué Zoo es point_of_interest 
Place.find(4).preferences << Preference.find(4)		# Quilpué Zoo es zoo

User.find(1).preferences << Preference.find(1)
User.find(1).preferences << Preference.find(2)
User.find(1).preferences << Preference.find(3)

User.find(2).preferences << Preference.find(2)
User.find(2).preferences << Preference.find(3)

User.find(3).preferences << Preference.find(1)
User.find(3).preferences << Preference.find(4)

User.find(4).preferences << Preference.find(2)

Rating.create([{user_id: 1, place_id: 1, rating: 4},
               {user_id: 1, place_id: 2, rating: 2},
               {user_id: 1, place_id: 4, rating: 1},
               {user_id: 2, place_id: 1, rating: 4},
               {user_id: 2, place_id: 2, rating: 1},
               {user_id: 2, place_id: 3, rating: 4},
               {user_id: 3, place_id: 2, rating: 5},
               {user_id: 3, place_id: 4, rating: 3},
               {user_id: 3, place_id: 3, rating: 1},
               {user_id: 4, place_id: 1, rating: 0},
               {user_id: 4, place_id: 2, rating: 3}])