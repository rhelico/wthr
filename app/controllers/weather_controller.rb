class WeatherController < ApplicationController
  def lookup
    latitude = params[:latitude]
    longitude = params[:longitude]
    Rails.logger.info "Looking up weather for lat: #{latitude}, lon: #{longitude}"

    begin
      client = OpenWeatherClient.new
      weather = client.current_weather(lat: latitude, lon: longitude)
      Rails.logger.info "Weather data: #{weather.to_h}"
      render json: weather.to_h
    rescue OpenWeatherClient::Unauthorized, OpenWeatherClient::NotFound, OpenWeatherClient::UnprocessableEntity => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end