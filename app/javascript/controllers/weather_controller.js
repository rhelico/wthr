import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weather"]

  connect() {
    document.addEventListener("addressSelected", this.fetchWeather.bind(this))
  }

  async fetchWeather(event) {
    console.log("Fetching weather data for location:", event.detail);
    const { latitude, longitude, postalCode } = event.detail;
    if (!latitude || !longitude) {
      this.displayError("Invalid location data. Please ensure you've selected a valid address.");
      return;
    }
    try {
      const response = await fetch(`/weather/lookup?latitude=${encodeURIComponent(latitude)}&longitude=${encodeURIComponent(longitude)}&postalCode=${encodeURIComponent(postalCode)}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
        },
      });

      if (!response.ok) {
        
        const errorData = await response.json();
        this.displayError(`Error from response: ${errorData.error || "Unknown error"}`);
        return;
      }
      
      const weatherData = await response.json();
      
      if (!weatherData || Object.keys(weatherData).length === 0) {
        console.log("No weather data available:", weatherData)
        this.displayError("No weather data available.");
        return;
      }
      
      this.displayWeatherData(weatherData);
    } catch (error) {
      console.error("Error fetching weather data from server:", error);
      this.displayError("Error fetching weather data from server. Please try again.");
    }
  }
  getDayOfWeek(unixTimestamp) {
    const date = new Date(unixTimestamp * 1000);
    return date.toLocaleDateString('en-US', { weekday: 'long' });
  }
  getBackgroundColor(temp) {
    console.log("Temp", temp);
    
    // Define the historical minimum and maximum temperatures
    const minTemp = -128.6; // Lowest recorded temperature on Earth (Vostok Station, Antarctica)
    const maxTemp = 134.1; // Highest recorded temperature on Earth (Furnace Creek Ranch, Death Valley, California)
    
    // Define the temperature thresholds for red and blue
    const redThreshold = 100;
    const blueThreshold = 40;
    
    // Calculate the normalized temperature value
    const normalizedTemp = (temp - minTemp) / (maxTemp - minTemp);
    
    // Calculate the hue value based on the normalized temperature
    let hue;
    if (temp >= redThreshold) {
      hue = 0; // Red color for temperatures above the red threshold
    } else if (temp <= blueThreshold) {
      hue = 240; // Blue color for temperatures below the blue threshold
    } else {
      hue = (1 - (temp - blueThreshold) / (redThreshold - blueThreshold)) * 240;
    }
    
    // Calculate the lightness value to ensure brightness for black fonts
    const lightness = Math.max(50, 90 - (normalizedTemp * 40));
    
    // Create the background color using the HSL color model
    const backgroundColor = `hsl(${hue}, 100%, ${lightness}%)`;
    
    return backgroundColor;
  }

  displayWeatherData(weatherData) {
    console.log("displaying weather data:", weatherData)
    const { today, tomorrow, next_day, cached } = weatherData;
    const days = [today, tomorrow, next_day];
   
    const cards = days.map((data, index) => {
      console.log("Data for day", index, data);
      if (!data || !data.temp || !data.weather) {
        return `<div class="p-4 bg-gray-100 rounded-lg m-2">Data missing for this day.</div>`;
      }
      const dayLabel = index === 0 ? "Today" : this.getDayOfWeek(data.dt);
      const weather_background_style = this.getBackgroundColor(data.temp.day || data.temp);
      
      return `
        <div class="p-4 rounded-lg m-2" style="background-color: ${ weather_background_style };">
          <h3 class="text-lg font-semibold mb-2">${dayLabel}</h3>
          ${
            data.temp.day !== undefined && data.temp.max !== undefined && data.temp.min !== undefined ?
            `<p><strong>Temperature:</strong> ${data.temp.day.toFixed(2)} °F (High: ${data.temp.max.toFixed(2)} °F, Low: ${data.temp.min.toFixed(2)} °F)</p>` :
            `<p><strong>Temperature:</strong> ${data.temp.toFixed(2)} °F</p>`
          }
          <p><strong>Description:</strong> ${data.weather[0].description}</p>
          <p><strong>Wind Speed:</strong> ${data.wind_speed.toFixed(2)} mph</p>
          <p><strong>Humidity:</strong> ${data.humidity}%</p>
        </div>
      `;

    }).join('');
    let cachedMessage = cached ? 'From the cache' : 'Fresh data from the cloudy skies';
    this.weatherTarget.innerHTML = cards + '<div class="p-4 bg-gray-100 rounded-lg mt-4">' + cachedMessage + '</div>';
    
  }

  displayError(errorMessage) {
    console.log(errorMessage);
    this.weatherTarget.innerHTML = `
      <div class="p-4 bg-red-100 rounded-lg">
        <p class="text-red-600">${errorMessage}</p>
      </div>
    `;
  }

}