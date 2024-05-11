import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["weather"]

  connect() {
    // needs to be document as the event bubbles up to the document
    // if you try to listen to the event on the element itself, it won't work
    document.addEventListener("addressSelected", this.fetchWeather.bind(this))
  }

  async fetchWeather(event) {
    const { latitude, longitude, postalCode } = event.detail
    try {
      const response = await fetch(`/weather/lookup?latitude=${encodeURIComponent(latitude)}&longitude=${encodeURIComponent(longitude)}&postalCode=${encodeURIComponent(postalCode)}`, {

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
        const errorData = await response.json()
        this.displayError(`Error from response: ${errorData.error || "Unknown error"}`)
      }
    } catch (error) {
      console.error("Error fetching weather data from server:", error)
      this.displayError("Error fetching weather data from server. Please try again.")
    }
  }

  displayWeatherData(weatherData) {
    const weatherElement = this.weatherTarget
    const temperature = weatherData.current?.temp ?? "N/A"
    const description = weatherData.current?.weather[0]?.description ?? "N/A"
    const windSpeed = weatherData.current?.wind_speed ?? "N/A"
    const humidity = weatherData.current?.humidity ?? "N/A"
    const cached = weatherData.cached 

    weatherElement.innerHTML = `
      <div class="p-4 bg-gray-100 rounded-lg">
        <h3 class="text-lg font-semibold mb-2">Current Weather</h3>
        <p><strong>Temperature:</strong> ${temperature} °C</p>
        <p><strong>Description:</strong> ${description}</p>
        <p><strong>Wind Speed:</strong> ${windSpeed} m/s</p>
        <p><strong>Humidity:</strong> ${humidity}%</p>
        <p><strong>From cache:</strong> ${cached}</p>
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
