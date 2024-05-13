require 'rails_helper'

RSpec.describe WeatherController, type: :controller do
  describe 'GET #weather_page' do
    let(:latitude) { 37.7749 }
    let(:longitude) { -122.4194 }
    let(:postal_code) { '94103' }
    let(:weather_service) { instance_double('Weather::WeatherService') }
    let(:weather_data_example) do
      { 
        "today" => {
          "dt" => 1715572990, 
          "sunrise" => 1715509979, 
          "sunset" => 1715562053, 
          "temp" => 71.8, 
          "feels_like" => 70.99, 
          "pressure" => 1009, 
          "humidity" => 49, 
          "dew_point" => 51.64, 
          "uvi" => 0, 
          "clouds" => 75, 
          "visibility" => 10000, 
          "wind_speed" => 14, 
          "wind_deg" => 188, 
          "wind_gust" => 20, 
          "weather" => [{"id" => 803, "main" => "Clouds", "description" => "broken clouds", "icon" => "04n"}]
        }, 
          "tomorrow" => {
            "dt" => 1715619600, 
            "sunrise" => 1715596317, 
            "sunset" => 1715648515, 
            "moonrise" => 1715613060, 
            "moonset" => 1715580540, 
            "moon_phase" => 0.19, 
            "summary" => "Expect a day of partly cloudy with rain", 
            "temp" => {"day" => 72.45, "min" => 56.32, "max" => 72.45, "night" => 56.32, "eve" => 62.58, "morn" => 61.63}, 
            "feels_like" => {"day" => 71.89, "night" => 56.21, "eve" => 62.67, "morn" => 60.55}, 
            "pressure" => 1007, 
            "humidity" => 53, 
            "dew_point" => 54.45, 
            "wind_speed" => 12.21, 
            "wind_deg" => 223, 
            "wind_gust" => 25.81, 
            "weather" => [{"id" => 502, "main" => "Rain", "description" => "heavy intensity rain", "icon" => "10d"}], 
            "clouds" => 75, 
            "pop" => 1, 
            "rain" => 21.14, 
            "uvi" => 7.15
          }, 
            "next_day" => {
              "dt" => 1715706000, 
              "sunrise" => 1715682656, 
              "sunset" => 1715734978, 
              "moonrise" => 1715703480, 
              "moonset" => 1715668920, 
              "moon_phase" => 0.23, 
              "summary" => "Expect a day of partly cloudy with rain", 
              "temp" => {"day" => 46.78, "min" => 46.53, "max" => 55.08, "night" => 47.21, "eve" => 48.51, "morn" => 48.63}, 
              "feels_like" => {"day" => 40.42, "night" => 42.08, "eve" => 42.71, "morn" => 43.84}, 
              "pressure" => 1010, 
              "humidity" => 84, 
              "dew_point" => 42.1, 
              "wind_speed" => 16.24, 
              "wind_deg" => 13, 
              "wind_gust" => 29.66, 
              "weather" => [{"id" => 500, "main" => "Rain", "description" => "light rain", "icon" => "10d"}], 
              "clouds" => 100, 
              "pop" => 1, 
              "rain" => 2.69, 
              "uvi" => 1.62
            } 
          }
        end
      

    before do
      allow(Weather::WeatherService).to receive(:new).and_return(weather_service)
      allow(weather_service).to receive(:get_weather).with(latitude: latitude, longitude: longitude, postal_code: postal_code).and_return(weather_data_example)
    end

    context 'when weather service returns valid data' do
      
      it 'returns a successful response' do
        get :weather_page, params: { latitude: latitude, longitude: longitude, postalCode: postal_code }
        expect(response).to be_successful
      end

   
    end

  
  end
end
