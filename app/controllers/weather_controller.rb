class WeatherController < ApplicationController
  include SemanticLogger::Loggable
  
  

  # Shows weather data based on lat/lon coordinates.
  #
  # @param latitude Latitude of the location.
  # @param longitude Longitude of the location.
  # @param postal_code Postal code of the location for caching purposes.
  # @param address Address of the location for display purposes.
  #
  # renders the weather display view at weather/index.html.erb
  def weather_page
    # Retrieve the query parameters
    latitude = params[:latitude].to_f
    longitude = params[:longitude].to_f
    address = params[:address]
    postal_code = params[:postalCode]
    
    missing_params = !latitude || !longitude || !address 
    # Fetch weather data
    unless missing_params
      weather_data = get_weather(latitude: latitude, longitude: longitude, postal_code: postal_code)
      if weather_data[:error]
        render json: { error: weather_data[:error] }, status: :unprocessable_entity
        return
      else
        show_weather(weather_data, address)
        return
      end
    end

    render :empty
  end

  private 

  def show_weather(weather_data, address)
     # restructure to for view
    days = {"today" => weather_data["today"], "tomorrow" => weather_data["tomorrow"], "next_day" => weather_data["next_day"]}

    days.each do |day, weather|
      logger.debug("Day: #{day}, Weather: #{weather}")
      days[day]["day_of_week"] = get_day_of_week(weather["dt"])  

      temperature = weather["temp"].is_a?(Float) ? weather["temp"] : weather["temp"]["day"] 
      days[day]["temperature"] = temperature
      days[day]["background_hue"] = get_background_hue(temperature)
    end
    
    cached = weather_data["cached"]

    # Render the search results view template
    render :show_weather, locals: { address: address, days: days, cached: cached }
  end
  # Converts a Unix timestamp to a day of the week.
  def get_day_of_week(unix_timestamp)
    Time.at(unix_timestamp).strftime('%A')
  end

  # provides a gradient of background colors based on temperature in Farenheit
  #
  # attempts to encode human norms of perception of color related to temperature
  #
  # @param temp [Float] the temperature in Farenheit
  def get_background_hue(temp)
    logger.debug("Temp: #{temp}")

    # Define the historical minimum and maximum temperatures
    min_temp = -128.6 # Lowest recorded temperature on Earth (Vostok Station, Antarctica)
    max_temp = 134.1  # Highest recorded temperature on Earth (Furnace Creek Ranch, Death Valley, California)
    
    # Define the temperature thresholds for red and blue
    red_threshold = 110
    blue_threshold = 0
    
    # Calculate the normalized temperature value
    normalized_temp = (temp - min_temp) / (max_temp - min_temp)
    
    # Calculate the hue value based on the normalized temperature
    hue =
      if temp >= red_threshold
        # Scale the hue from red at red_threshold to more intense red at max_temp
        0 * (1 - (temp - red_threshold) / (max_temp - red_threshold)) # Remains at 0 (red)
      elsif temp <= blue_threshold
        # Scale the hue from blue at blue_threshold to more intense blue at min_temp
        240 * (1 - (blue_threshold - temp) / (blue_threshold - min_temp)) # Remains at 240 (blue)
      else
        # Calculate the hue for temperatures between blue_threshold and red_threshold
        240 * (1 - (temp - blue_threshold) / (red_threshold - blue_threshold))
      end
    
    hue
  end
  # Fetches weather data based on geographical coordinates and postal code.
  #
  # @param latitude [Float] Latitude of the location.
  # @param longitude [Float] Longitude of the location.
  # @param postal_code [String] Postal code of the location for caching purposes.
  #
  # @return [Hash] Returns weather data or an error message.
  #   - On success: A hash with keys for temperature, humidity, and description of the weather.
  #   - On error: A hash containing an 'error' key with a descriptive message.
  #
  # Possible errors:
  # - Missing or invalid latitude/longitude will result in a 422 Unprocessable Entity status.
  # - Any unexpected errors during data retrieval will also result in a 422 status with a general error message.
  def get_weather(latitude:, longitude:, postal_code:)
    # Log the latitude and longitude for debugging and tracing purposes
    logger.debug "Looking up weather for latitude: #{latitude}, longitude: #{longitude}, postal_code: #{postal_code}"

    begin
      weather_service = Weather::WeatherService.new
      weather = weather_service.get_weather(latitude: latitude, longitude: longitude, postal_code: postal_code)
      if weather[:error]
        logger.error "Error in WeatherService response", error: weather[:error]
        return weather
      else
        logger.debug "Weather data fetched successfully"
        return weather
      end
    rescue StandardError => e
      logger.error "Exception fetching weather data", exception: e
      return { error: "An unexpected error occurred while fetching weather data" }
    end
  end
end
