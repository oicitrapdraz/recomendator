# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
key = "TPSW_servidor"
User.create([{name: "Ricardo", password: AESCrypt.encrypt("hola123", key), android_id: "5fg8", email: "ricardo@gmail.com"}, {name: "Ruben",password: AESCrypt.encrypt("hola1234", key) ,android_id: "5fg7", email: "ruben@gmail.com"}])

Preference.create([{ type_of_place: "point_of_interest" }, { type_of_place: "museum" }, { type_of_place: "movie_theater" }, { type_of_place: "zoo" }])

User.find(1).preferences << Preference.find(1) unless User.find(1).preferences.include?(Preference.find(1))
User.find(1).preferences << Preference.find(2) unless User.find(1).preferences.include?(Preference.find(2))

User.find(2).preferences << Preference.find(1) unless User.find(2).preferences.include?(Preference.find(1))
User.find(2).preferences << Preference.find(2) unless User.find(2).preferences.include?(Preference.find(2))
User.find(2).preferences << Preference.find(3) unless User.find(2).preferences.include?(Preference.find(3))