require 'net/http'
require 'uri'
require 'json/ext'
require 'rubygems'
require 'pp'

class LocationController < ApplicationController
  def index
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
      #logger.info(@obj['results'][0]['place_id'])
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
      
			#render json: response.body
      #render :index,  status: :ok ,location: @obj
		end
  end

  private

  def location_params
  	params.require(:location).permit(:address)
  end
end
