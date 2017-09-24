require 'net/http'
require 'uri'

class LocationController < ApplicationController
  def search
   	uri = URI.parse("https://maps.googleapis.com/maps/api/geocode/json?address=#{location_params}&key=AIzaSyAiwucziMi6iEJHK5Wyl7TEFpiJQrVdbgo")
  	request = Net::HTTP::Get.new(uri)
  	request["X-Riot-Token"] = "RGAPI-ade1178e-06bd-48a2-90fc-1b1a5080ad3c"

  	req_options = {
  		use_ssl: uri.scheme == "https",
  	}

		response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		  http.request(request)
		end

		if response.code == "200"
			render json: response.body
		end
  end

  private

  def location_params
  	params.require(:location).permit(:address)
  end
end
