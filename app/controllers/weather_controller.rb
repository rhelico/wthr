class WeatherController < ApplicationController
  include SemanticLogger::Loggable
# This endpoint provides weather data based on geographical coordinates and postal code.
  # It serves as the backend service for clients needing weather data.
  #
  # @param latitude [Float] Latitude of the location.
  # @param longitude [Float] Longitude of the location.
  # @param postalCode [String] Postal code of the location for caching purposes.
  #
  # @return [JSON] Returns weather data or an error message.
  #   - On success: A JSON object with keys for temperature, humidity, and description of the weather.
  #   - On error: A JSON object containing an 'error' key with a descriptive message.
  #
  # Possible errors:
  # - Missing or invalid latitude/longitude will result in a 422 Unprocessable Entity status.
  # - Any unexpected errors during data retrieval will also result in a 422 status with a general error message.
  def lookup
    # Convert latitude and longitude parameters to floats
    # This prevents potential type mismatch errors and ensures I have numbers!
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    postal_code = params[:postalCode].to_s

   
    # Log the latitude and longitude for debugging and tracing purposes
    logger.debug "Looking up weather for latitude: #{latitude}, longitude: #{longitude}, postal_code: #{postal_code}"

    begin
      weather_service = Weather::WeatherService.new
      logger.debug "defined new weather_service"
      weather = weather_service.get_weather(latitude: latitude, longitude: longitude, postal_code: postal_code)
      logger.debug "got weather data #{weather.inspect}"
      if weather[:error]
        logger.error "Error in WeatherService response", error: weather[:error]

        # Render a JSON response with the error message and a 422 Unprocessable Entity status code
        render json: { error: weather[:error] }, status: :unprocessable_entity
      else
        logger.debug "Rendering weather data"
        render json: weather
      end
    rescue StandardError => e
      # i want to log to both stderr and provide a message for the client. sweet!
      logger.error "Exception fetching weather data", exception: e
      render json: { error: "An unexpected error occurred while fetching weather data" }, status: :unprocessable_entity
    end
  end
end