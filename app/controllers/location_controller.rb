class LocationController < ApplicationController
  def search
  end

  private

  def location_params
  	params.require(:location).permit(:address)
  end
end
