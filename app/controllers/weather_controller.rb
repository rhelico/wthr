class WeatherController < ApplicationController
  include SemanticLogger::Loggable
  # Endpoint for weather lookup based on latitude and longitude.
  #
  # The client needs a place to call to get weather data based on latitude and longitude,
  # this is that endpoint.
  #
  # @param [Float] latitude The latitude of the location to fetch weather for.
  # @param [Float] longitude The longitude of the location to fetch weather for.
  #
  # @return [JSON] Contains weather data or an error message.
  #   - On success, the response will be a hash with the following keys:
  #     - temperature [Float]: The current temperature in degrees Celsius.
  #     - humidity [Float]: The current humidity as a value between 0 and 1.
  #     - description [String]: A brief description of the current weather conditions.
  #   - On error, the response will be a hash with the following key:
  #     - error [String]: A message describing the error that occurred.
  #
  # Errors:
  # - If the latitude or longitude parameters are missing or invalid, a 422 Unprocessable Entity
  #   response will be returned with an error message.
  # - If an unexpected error occurs while fetching weather data, a 422 Unprocessable Entity
  #   response will be returned with a generic error message.
  #
  # Testing:
  # - Logging that is inspected by tests has messages prefixed with "TESTABLE:"
  #   If you want different logging, you can change the test or leave it unchanged
  #   and add new logging that isn't in conflict with the test.
  def lookup
    # Convert latitude and longitude parameters to floats
    # This prevents potential type mismatch errors and ensures I have numbers!
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f

    # Log the latitude and longitude for debugging and tracing purposes
    logger.debug "TESTABLE: Looking up weather for latitude: #{latitude}, longitude: #{longitude}"

    begin
      weather_service = Weather::WeatherService.new

      # Retrieve the weather data from the WeatherService
      #
      # @param [Float] latitude
      # @param [Float] longitude
      #
      # @return [Hash] Weather data hash or hash with error message
      weather = weather_service.get_weather(latitude: latitude, longitude: longitude)

      if weather[:error]
        logger.error "Error in WeatherService response", error: weather[:error]

        # Render a JSON response with the error message and a 422 Unprocessable Entity status code
        render json: { error: weather[:error] }, status: :unprocessable_entity
      else
        render json: weather
      end
    rescue StandardError => e
      # i want to log to both stderr and provide a message for the client. sweet!
      logger.error "TESTABLE: Exception fetching weather data", exception: e
      render json: { error: "An unexpected error occurred while fetching weather data" }, status: :unprocessable_entity
    end
  end
end