require 'net/http'
require 'uri'
require 'json/ext'
require 'rubygems'
require 'pp'

class LocationController < ApplicationController
  def index
  end
  def show
  end
  def search
   	uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{location_params}&key=AIzaSyAiwucziMi6iEJHK5Wyl7TEFpiJQrVdbgo")
  	#uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJy3Hiyy3hiZYRW6QgSYptxrg&key=AIzaSyDqBVFE2MRz8AERZoHM6jqsVZ2f7LMfN8g")

    request = Net::HTTP::Get.new(uri)
  	request["X-Riot-Token"] = "RGAPI-ade1178e-06bd-48a2-90fc-1b1a5080ad3c"

  	req_options = {
  		use_ssl: uri.scheme == "https",
  	}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end

		if response.code == "200"
      
      @obj = JSON.parse(response.body)

      # Obtener el placeID
      place_id = @obj['results'][0]['place_id']
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/details/json?placeid=#{place_id}&key=AIzaSyDqBVFE2MRz8AERZoHM6jqsVZ2f7LMfN8g")
      request = Net::HTTP::Get.new(uri)
      
      response_details = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end

      if response_details.code == "200"
        render json: response_details.body
      end
      
		end
  end

  ## Función para recomendar basado en dos campos
  ## {"rating": Por rating , "distance": Por distancia} 

  def recommendation

    #Obtener latitud y longitud de una dirección
    if locationOwner_params[:address]
      uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{locationOwner_params[:address]}&key=AIzaSyAiwucziMi6iEJHK5Wyl7TEFpiJQrVdbgo")

      request = Net::HTTP::Get.new(uri)
      request["X-Riot-Token"] = "RGAPI-ade1178e-06bd-48a2-90fc-1b1a5080ad3c"

      req_options = {
        use_ssl: uri.scheme == "https",
      }

      response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
        http.request(request)
      end


      if response.code == "200"
        logger.info("entra")
        jsonQuery = JSON.parse(response.body)
        
        location = jsonQuery['results'][0]['geometry']['location']['lat'].to_s + "," +
        jsonQuery['results'][0]['geometry']['location']['lng'].to_s
        
      else
        #Hacer un manejo de error para devolver error.
        render json: response.msg, status: :unprocessable_entity
      end
    else
      location = locationOwner_params[:location]
    end



    #URL que manda latitud,longitud y tag.
    #Obtener lugares cercanos a un radio definido.
    if locationOwner_params[:recommend] == "distance"
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{locationOwner_params[:type]}&key=AIzaSyDqBVFE2MRz8AERZoHM6jqsVZ2f7LMfN8g")
    elsif locationOwner_params[:recommend] == "rating"      
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=500&type=#{locationOwner_params[:type]}&key=AIzaSyDqBVFE2MRz8AERZoHM6jqsVZ2f7LMfN8g")
    end

    request = Net::HTTP::Get.new(uri)
    request["X-Riot-Token"] = "RGAPI-ade1178e-06bd-48a2-90fc-1b1a5080ad3c"

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    #Si la consulta se hizo con exito
    if response.code == "200"
      
      #Parsear a JSON
      @jsonResult = JSON.parse(response.body)
      list = []

      #Obtener el token para sacar la sgte pagina de resultados.
      nextPageToken = @jsonResult['next_page_token']
      list.push(@jsonResult['results']) #Se guardan los resultados en una lista.

      # Google solo muestra 20 resultados minimos y 60 maximos, para acceder a los prox.
      # 20 resultados, se utiliza el next_page_token.
      while nextPageToken do        
          
        #El tiempo para entregar un token y validarlo, no es rapido (no menos de 1.5 segundo).
        sleep 1.6
        
        if locationOwner_params[:recommend] == "distance"
          uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{locationOwner_params[:type]}&pagetoken=#{nextPageToken}&key=AIzaSyDqBVFE2MRz8AERZoHM6jqsVZ2f7LMfN8g")
        elsif locationOwner_params[:recommend] == "rating"      
          uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=500&type=#{locationOwner_params[:type]}&pagetoken=#{nextPageToken}&key=AIzaSyDqBVFE2MRz8AERZoHM6jqsVZ2f7LMfN8g")
        end

        request = Net::HTTP::Get.new(uri)
        request["X-Riot-Token"] = "RGAPI-ade1178e-06bd-48a2-90fc-1b1a5080ad3c"

        req_options = {
          use_ssl: uri.scheme == "https",
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        if response.code == "200"

          @jsonResult = JSON.parse(response.body)
          list[0]=list[0]+@jsonResult['results']          #Añadir la nueva lista de resultados.
          nextPageToken = @jsonResult['next_page_token']  #Obtener el next_page_token para la sgte pagina.
        else
          #Hacer un manejo de error para devolver error.
          render json: response.msg, status: :unprocessable_entity
        end
      end

      #Ordenar por
      # {
      #  "rating": Ordenar por rating
      #  "distance": Ordenar por distancia
      # }
      if locationOwner_params[:recommend] == "rating"
        list = bubble_sort(list[0])
        @list2 = list.first(10)
      elsif locationOwner_params[:recommend] == "distance"
        @list2 = list[0].first(10)
      end
      
      #Entregar los primeros 10 resultados.
      render :show, status: :ok, location: @list2.to_json
    else
        #Hacer un manejo de error para devolver error.
        render json: response.msg, status: :unprocessable_entity
    end

  end

  private

  def bubble_sort(list)
    return list if list.size <= 1 # ya esta ordenado.
    swapped = true
    while swapped do
      swapped = false
      0.upto(list.size-2) do |i|
        number = list[i]["rating"].to_f
        number2 = list[i+1]["rating"].to_f
        if number > number2
          list[i], list[i+1] = list[i+1], list[i] # cambia lugares.
          swapped = true
        end
      end
    end

    list.reverse
  end

  def location_params
  	params.require(:location).permit(:address)
  end

  def locationOwner_params
    params.require(:data).permit(:address,:location,:type,:recommend)
  end
end
