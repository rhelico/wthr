import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weather"]

  connect() {
    document.addEventListener("addressSelected", this.fetchWeather.bind(this))
  }
  //let stimulus handle the disconnect, not declaring it explicitly here.

  async fetchWeather(event) {
    const { latitude, longitude } = event.detail
    try {
      const response = await fetch(`/weather/lookup?latitude=${latitude}&longitude=${longitude}`, {
        method: "GET",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').getAttribute("content"),
        },
      })

      if (response.ok) {
        const weatherData = await response.json()
        this.displayWeatherData(weatherData)
      } else {
        const error = await response.json()
        this.displayError(error.error)
      }
    } catch (error) {
      console.error("Error fetching weather data:", error)
      this.displayError("Error fetching weather data. Please try again.")
    }
  }

  displayWeatherData(weatherData) {
    const weatherElement = this.weatherTarget
    weatherElement.innerHTML = `
      <div class="p-4 bg-gray-100 rounded-lg">
        <h3 class="text-lg font-semibold mb-2">Current Weather</h3>
        <p><strong>Temperature:</strong> ${weatherData.current.temp} °C</p>
        <p><strong>Description:</strong> ${weatherData.current.weather[0].description}</p>
        <p><strong>Wind Speed:</strong> ${weatherData.current.wind_speed} m/s</p>
        <p><strong>Humidity:</strong> ${weatherData.current.humidity}%</p>
      </div>
    `
  }

  displayError(errorMessage) {
    const weatherElement = this.weatherTarget
    weatherElement.innerHTML = `
      <div class="p-4 bg-red-100 rounded-lg">
        <p class="text-red-600">${errorMessage}</p>
      </div>
    `
  }
}