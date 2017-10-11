require 'net/http'
require 'uri'

class LocationController < ApplicationController

  # Endpoint para obtener varios detalles de algun lugar en especifico, se reciben parametros JSON con el formato:

  # {
  #   "location": {
  #     "address":   
  #   }
  # }

  def search
   	uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{location_params}&key=#{G_API_KEY}")

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
        render json: response.msg
      end
      
		end
  end

  # Endpoint para retornar una recomendacion, se reciben parametros JSON con el formato:

  # {
  #   "data": {
  #     "address":
  #     "type":
  #     "recommend":
  #   }
  # }

  def recommendation
    if locationOwner_params[:address]
      uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{locationOwner_params[:address]}&key=#{G_API_KEY}")

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
          render json: response.msg
      end
    else
      location = locationOwner_params[:location]
    end

    if locationOwner_params[:recommend] == "distance"
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{locationOwner_params[:type]}&key=#{G_API_KEY}")
    elsif locationOwner_params[:recommend] == "rating"      
      uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=500&type=#{locationOwner_params[:type]}&key=#{G_API_KEY}")
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
        
        if locationOwner_params[:recommend] == "distance"
          uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&rankby=distance&type=#{locationOwner_params[:type]}&pagetoken=#{nextPageToken}&key=#{G_API_KEY}")
        elsif locationOwner_params[:recommend] == "rating"      
          uri = URI.parse("https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=#{location}&radius=500&type=#{locationOwner_params[:type]}&pagetoken=#{nextPageToken}&key=#{G_API_KEY}")
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
          render json: response.msg
        end
      end

      if locationOwner_params[:recommend] == "rating"
        result = list.sort_by {|obj| -obj["rating"].to_f }.first(10)
      elsif locationOwner_params[:recommend] == "distance"
        result = list.first(10)
      end
      
      render json: result
    else
      render json: response.msg
    end

  end

  private

    def location_params
    	params.require(:location).permit(:address)
    end

    def locationOwner_params
      params.require(:data).permit(:address, :location, :type, :recommend)
    end

end