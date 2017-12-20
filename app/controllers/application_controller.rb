class ApplicationController < ActionController::API
	include ActionController::HttpAuthentication::Basic::ControllerMethods
  	G_API_KEY = "AIzaSyD-Q728iX5pzaMmtJGrpvfZVnPDfp2ay7U"
  	#G_API_KEY = "AIzaSyCbz-oDqIOZ9QgEQJmnQfzs1Rlff8YiuMQ"
end
