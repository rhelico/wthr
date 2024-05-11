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
    if (temp >= 100) return 'bg-red-100';    // Super hot
    if (temp >= 80) return 'bg-orange-100'; // hot
    if (temp >= 70) return 'bg-yellow-100'; // warm
    if (temp >= 50) return 'bg-white';    // mild
    if (temp >= 40) return 'bg-blue-100';    // Cool
    return 'bg-blue-300';                      // Cold
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
      const bgColor = this.getBackgroundColor(data.temp.day || data.temp);
      
      return `
        <div class="p-4 ${bgColor} rounded-lg m-2">
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

    this.weatherTarget.innerHTML = cards + (cached ? `<div class="p-4 bg-gray-100 rounded-lg mt-4">Data from cache</div>` : '');
    
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