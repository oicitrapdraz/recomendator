require 'net/http'
require 'uri'
require 'set'
require 'json'

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
          sleep(1.606)

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

          jsonResult = JSON.parse(response.body)

          # Obtener el token para sacar la sgte pagina de resultados y guardamos los resultados en una lista

          nextPageToken = jsonResult['next_page_token']
          list = jsonResult['results']

          # Google solo muestra 20 resultados minimos y 60 maximos, para acceder a los prox 20 resultados, se utiliza next_page_token

          while nextPageToken do
            sleep(1.606)

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

      result = result.reject{ |r|
        !(types - r['types']).empty?
      }

      result = result.sort_by {|obj| -obj['rating'].to_f }.first(10)

      render json: result
    else
      render json: { status: :internal_server_error }
    end
  end

  def recommendation_by_collaborative_filtering
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
    
    
    #user_data = {
    #  "rob" => {
    #    "RecreoTV" => 5,
    #    "Museo del Piano" => 4,
    #    "Sushi Express" => 3
    #  },
    #  "bob" => {
    #    "RecreoTV" => 2,
    #    "Museo USM" => 1,
    #    "Sushi Express" => 4
    #  },
    #  "tod" => {
    #    "RecreoTV" => 3,
    #    "Museo del Piano" => 3,
    #    "Sushi Express" => 5,
    #    "Museo USM" => 3
    #  },
    #  "dod" => {
    #    "RecreoTV" => 2,
    #    "Museo del Piano" => 1,
    #    "Sushi Express" => 2,
    #    "Nony's" => 5
    #  },
    #  "fod" => {
    #    "Museo del Piano" => 1,
    #    "Sushi Express" => 2,
    #    "Nony's" => 3
    #  }
    #}
    foo = {}
    user = User.find(params[:id])
    ratUser = Rating.where(user_id: user.id)
    ratUser.each { |ratUser|
      place = Place.find(ratUser.place_id)
      foo[place.name] = ratUser.rating      
    }
    #logger.info(foo)
    
    slope_one = SlopeOne.new
    slope_one.insert(user_data)
    #slope_one.insert(lista)
    #recom = eval(slope_one.predict({"Sushi Express" => 3, "Museo USM" => 5}).inspect)
    #recom.each {|key,value|
    #  logger.info(key)
    #  if value > 5
    #    value = 5
    #  end  
    #}
    recommend = eval(slope_one.predict(foo).inspect)
    recommend.each {|key,value|
      if value > 5
        value = 5
      end  
    }
    
    #render json: recom, status: :ok
    render json: recommend, status: :ok
  end


  private

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
