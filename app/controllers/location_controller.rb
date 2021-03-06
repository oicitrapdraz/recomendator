require 'net/http'
require 'uri'
require 'set'
require 'json'
require 'ruby-esvidi'

class LocationController < ApplicationController

  # Endpoint para obtener varios detalles de algun lugar en especifico, se reciben parametros JSON con el formato:

  # {
  #   "location": {
  #     "address":   
  #   }
  # }

  def search
    uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{search_params}&key=#{G_API_KEY}")
    request = Net::HTTP::Get.new(uri)
    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code == "200"
      obj = JSON.parse(response.body)

      place_id = obj['results'][0]['place_id']
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&key=#{G_API_KEY}")
      request = Net::HTTP::Get.new(uri)

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code == "200"
        render json: response.body
      else
        render json: { status: :internal_server_error }
      end
    else
      render json: { status: :internal_server_error }
    end
  end

  # Endpoint para retornar una recomendacion, se reciben parametros JSON con el formato:

  # {
  #   "data": {
  #     "address":
  #     "location":
  #     "type":
  #     "recommend":
  #     "radius":
  #   }
  # }

  def recommendation
    if recommendation_params[:address]
      uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{recommendation_params[:address]}&key=#{G_API_KEY}")

      request = Net::HTTP::Get.new(uri)

      req_options = {  
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code == "200"
        jsonQuery = JSON.parse(response.body)

        location = jsonQuery['results'][0]['geometry']['location']['lat'].to_s + "," + jsonQuery['results'][0]['geometry']['location']['lng'].to_s
      else
        render json: { status: :internal_server_error }
      end
    else
      location = recommendation_params[:location]
    end

    types = recommendation_params[:type].split(",")
    result = []

    types.each { |type|
      if recommendation_params[:recommend] == "distance"
        uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{type}&key=#{G_API_KEY}")
      elsif recommendation_params[:recommend] == "rating"      
        uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=#{recommendation_params[:radius]}&type=#{type}&key=#{G_API_KEY}")
      end

      request = Net::HTTP::Get.new(uri)

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code == "200"
        jsonResult = JSON.parse(response.body)

        # Obtener el token para sacar la sgte pagina de resultados y guardamos los resultados en una lista

        nextPageToken = jsonResult['next_page_token']
        list = jsonResult['results']

        # Google solo muestra 20 resultados minimos y 60 maximos, para acceder a los prox 20 resultados, se utiliza next_page_token

        while nextPageToken do
          sleep(1.61)

          if recommendation_params[:recommend] == "distance"
            uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{recommendation_params[:type]}&pagetoken=#{nextPageToken}&key=#{G_API_KEY}")
          elsif recommendation_params[:recommend] == "rating"      
            uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=#{recommendation_params[:radius]}&type=#{recommendation_params[:type]}&pagetoken=#{nextPageToken}&key=#{G_API_KEY}")
          end

          request = Net::HTTP::Get.new(uri)

          req_options = {
            use_ssl: uri.scheme == "https",
          }

          response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
            http.request(request)
          end

          if response.code == "200"
            jsonResult = JSON.parse(response.body)
            list.concat jsonResult['results']
            nextPageToken = jsonResult['next_page_token']
          else
            render json: { status: :internal_server_error }
          end
        end

        result.concat list        
      else
        render json: { status: :internal_server_error }
      end
    }

    result = result.reject{ |r|
      !(types - r['types']).empty?
    }

    if recommendation_params[:recommend] == "rating"
      result = result.sort_by {|obj| -obj['rating'].to_f }.first(10)
    elsif recommendation_params[:recommend] == "distance"
      result = result.first(10)
    end

    render json: result
  end

  # Endpoint para retornar una recomendacion, se reciben parametros JSON con el formato:

  # {
  #   "data": {
  #     "android_id":
  #     "address":
  #     "location":
  #     "radius":
  #   }
  # }

  def recommendation_by_preferences
    user = User.find_by_android_id(recommendation_by_preferences_params[:android_id])

    if user
      types = user.preferences.map{ |p| p.type_of_place }

      if recommendation_by_preferences_params[:address]
        uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{recommendation_by_preferences_params[:address]}&key=#{G_API_KEY}")

        request = Net::HTTP::Get.new(uri)

        req_options = {  
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        if response.code == "200"
          jsonQuery = JSON.parse(response.body)

          location = jsonQuery['results'][0]['geometry']['location']['lat'].to_s + "," + jsonQuery['results'][0]['geometry']['location']['lng'].to_s
        else
          render json: { status: :internal_server_error }
        end
      else
        location = recommendation_by_preferences_params[:location]
      end

      result = []
      list={}

      types.each { |type|
        uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=#{recommendation_by_preferences_params[:radius]}&type=#{type}&key=#{G_API_KEY}")

        request = Net::HTTP::Get.new(uri)

        req_options = {
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        if response.code == "200"
          logger.info(response.body)

          jsonResult = JSON.parse(response.body)

          # Obtener el token para sacar la sgte pagina de resultados y guardamos los resultados en una lista

          nextPageToken = jsonResult['next_page_token']
          list = jsonResult['results']

          # Google solo muestra 20 resultados minimos y 60 maximos, para acceder a los prox 20 resultados, se utiliza next_page_token

          while nextPageToken do
            sleep(1.61)

            uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=#{recommendation_by_preferences_params[:radius]}&type=#{recommendation_by_preferences_params[:type]}&pagetoken=#{nextPageToken}&key=#{G_API_KEY}")

            request = Net::HTTP::Get.new(uri)

            req_options = {
              use_ssl: uri.scheme == "https",
            }

            response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
              http.request(request)
            end

            if response.code == "200"
              jsonResult = JSON.parse(response.body)
              list.concat jsonResult['results']
              nextPageToken = jsonResult['next_page_token']
            else
              render json: { status: :internal_server_error }
            end
          end

          result.concat list        
        else
          render json: { status: :internal_server_error }
        end
      }

      #result = result.reject{ |r|
      #  !(types - r['types']).empty?
      #}

      result = result.sort_by {|obj| -obj['rating'].to_f }.first(10)

      render json: result
    else
      render json: { status: :internal_server_error }
    end
  end

  def recommendation_by_collaborative_filtering
    user = User.find(params[:id])

    num_users = User.count - 1
    num_places = Place.count

    map_user_col = Hash.new()   # Para mapear user_id a columna
    map_place_row = Hash.new()  # Para mapear place_id a fila

    user_ids = User.where.not(id: user.id).ids
    place_ids = Place.ids

    user_ids.each_with_index { |user_id, i|
      map_user_col[user_id] = i
    }

    place_ids.each_with_index { |place_id, i|
      map_place_row[place_id] = i
    }

    matrix = Array.new(num_places) { Array.new(num_users, 0) }

    ratings = Rating.where.not(user_id: user.id)

    ratings.each do |rating|
      matrix[map_place_row[rating.place_id]][map_user_col[rating.user_id]] = rating.rating
    end

    m = SVDMatrix.new(num_places, num_users)

    matrix.each_with_index do |row, i|
      m.set_row(i, row)
    end

    lsa = LSA.new(m)

    user_places = Array.new(num_places, 0)

    ratings_from_user = Rating.where(user_id: user.id)

    ratings_from_user.each_with_index do |rating,|
      user_places[map_place_row[rating.place_id]] = rating.rating
    end

    similarity = lsa.classify_vector(user_places)

    similar_users = similarity.delete_if { |k, sim| sim < 0.5 }.sort{ |a| -a[1] }

    similar_users_ids = []   # Aqui tendremos una lista de los IDs de los usuarios similares

    similar_users.each do |u|
      similar_users_ids.push(map_user_col.key(u[0]))
    end

    p similar_users_ids

    recommended_places = []

    similar_users_ids.each do |u_id|
      recommended_places.concat Rating.where(user_id: u_id).where(rating: 4..5).order('rating DESC').pluck(:place_id)
    end

    recommended_places = recommended_places.uniq - Rating.where(user_id: user.id).pluck(:place_id)

    render json: Place.find(recommended_places), status: :ok
  end


  # Endpoint para registrar un rating a un lugar, se reciben parametros JSON con el formato:

  # {
  #   "data": {
  #     "user_id":
  #     "place_id":
  #     "rating":
  #   }
  # }

  def rating_place

    ##recibe el place_id, busca el lugar.
    ##registra el rating en base al place_id de la BD (no de google) y user_id.
    @rating = Rating.new
    @place = Place.find_by(google_id: rating_params[:place_id])
    
    if @place
      #logger.info("hay algo")
      #logger.info(@place.to_json)      
      @rating.place_id = @place.id
      @rating.user_id = rating_params[:user_id]
      @rating.rating = rating_params[:rating].to_i
      if @rating.save
        render json: @rating.to_json, status: :ok
      else
        render json: @rating.errors, status: :unprocessable_entity
      end
    else

      uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{rating_params[:place_id]}&key=#{G_API_KEY}")

      request = Net::HTTP::Get.new(uri)

      req_options = {  
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response.code == "200"
        jsonQuery = JSON.parse(response.body)

        place = Place.new
        place.google_id = jsonQuery['result']['place_id']
        place.name = jsonQuery['result']['name']
        place.vicinity = jsonQuery['result']['vicinity']
        place.icon = jsonQuery['result']['icon']   
        location = jsonQuery['result']['geometry']['location']['lat'].to_s + "," + jsonQuery['result']['geometry']['location']['lng'].to_s
        place.location = location


        if place.save
          @rating.place_id = place.id
          @rating.user_id = rating_params[:user_id]
          @rating.rating = rating_params[:rating].to_i
          if @rating.save
            render json: @rating.to_json, status: :ok
          else
            render json: @rating.errors, status: :unprocessable_entity
          end
        else
          render json: place.errors, status: :unprocessable_entity
        end

      else
        render json: { status: :internal_server_error }
      end




      #render json: @place, status: :unprocessable_entity
    end
  end

  def recommendation_by_collaborative_filtering_slope
    usuarios = User.where.not(id: params[:id])
    lista = {}
    
    usuarios.each { |usuario|
      foo = {}
      ratings = Rating.where(user_id: usuario.id)
      ratings.each { |rat|

        place = Place.find(rat.place_id)
        foo[place.name] = rat.rating      
      }

      lista[usuario.name] = foo
      
    }
    logger.info(lista)
    
    
    foo = {}
    user = User.find(params[:id])
    ratUser = Rating.where(user_id: user.id)

    ratUser.each { |ratUser|
      place = Place.find(ratUser.place_id)
      foo[place.name] = ratUser.rating      
    }
    resultados = []
    fooMiamigo = {}
    slope_one = SlopeOne.new
    slope_one.insert(lista)
    i = 0
    recommend = eval(slope_one.predict(foo).inspect)
    recommend.each {|key,value|
      logger.info(key)
      logger.info(value)
      lugares = Place.find_by(name: key)
      value = value.round
      logger.info(value)
      if value > 5
        value = 5
      end 
      recommend[key] = value
      fooMiamigo['name'] = key
      fooMiamigo['place_id'] = lugares.google_id
      fooMiamigo['rating'] = value
      resultados[i] = fooMiamigo
      fooMiamigo = {}
      i = i +1
    }
    logger.info(fooMiamigo)
    
    #render json: recom, status: :ok
    render json: resultados, status: :ok
  end

  def recommendation_by_collaborative_filtering_with_svd
    user = User.find(params[:id])
    ratingEstimate = user.get_place_recommendations
    render json: ratingEstimate, status: :ok
  end

  # Endpoint para mostrar el rating hecho a un lugar, por un usuario especifico se reciben parametros JSON con el formato:


  def rating_show

    @rating = Rating.where(user_id: params[:id]).joins(:place).select("ratings.id,
      ratings.user_id,ratings.rating,places.google_id")
    render json: @rating.to_json, status: :ok
  end


  private

  def rating_params
    params.require(:data).permit(:place_id,:user_id,:rating)
  end

  def search_params
    params.require(:location).permit(:address)
  end

  def recommendation_params
    params.require(:data).permit(:address, :location, :type, :recommend, :radius)
  end

  def recommendation_by_preferences_params
    params.require(:data).permit(:android_id, :address, :location, :radius)
  end
end
