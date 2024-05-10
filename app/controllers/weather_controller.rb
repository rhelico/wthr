class WeatherController < ApplicationController
  include SemanticLogger::Loggable
  def lookup
    # Convert to floats to prevent errors
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f

    logger.info "Looking up weather for lat: #{latitude}, lon: #{longitude}"

    begin
      weather_service = Weather::WeatherService.new
      weather = weather_service.get_weather(latitude: latitude, longitude: longitude)

      if weather[:error]
        Rails.logger.error "Error in WeatherService response: #{weather[:error]}"
        render json: { error: weather[:error] }, status: :unprocessable_entity
      else
        render json: weather
      end
    rescue StandardError => e
      logger.error "Error fetching weather data: #{e.message}"
      render json: { error: "Error fetching weather data: #{e.message}" }, status: :unprocessable_entity
    end
  end
end
