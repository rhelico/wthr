import { Controller } from "@hotwired/stimulus"
import debounce from "lodash/debounce"

export default class extends Controller {
  static targets = ["query", "results", "latitude", "longitude"]

  connect() {
    console.log("Address autocomplete controller connected.")
    this.queryTarget.addEventListener("input", debounce(this.suggest.bind(this), 300))
  }

  async suggest() {
    const query = this.queryTarget.value
    console.log(`Query input: ${query}`)

    if (query.length < 3) {
      console.log("Query too short. No search initiated.")
      this.resultsTarget.innerHTML = ""
      return
    }

    try {
      const response = await fetch(`/addresses/autocomplete?query=${encodeURIComponent(query)}`)
      const addresses = await response.json()

      console.log(`Fetched addresses: ${JSON.stringify(addresses)}`)

      if (addresses.length > 0) {
        this.resultsTarget.innerHTML = addresses.map(address => `
          <div class="cursor-pointer px-2 py-1 hover:bg-gray-200" data-action="click->address-autocomplete#select" data-address-autocomplete-address='${JSON.stringify(address)}'>
            ${address.formatted_address}
          </div>
        `).join("")
      } else {
        this.resultsTarget.innerHTML = `<div class="px-2 py-1">No results found</div>`
      }
    } catch (error) {
      console.error(`Autocomplete fetch error: ${error.message}`)
      this.resultsTarget.innerHTML = `<div class="px-2 py-1">Error fetching results</div>`
    }
  }

  select(event) {
    const selectedAddress = JSON.parse(event.target.dataset.addressAutocompleteAddress)
    console.log(`Selected address: ${JSON.stringify(selectedAddress)}`)
    this.queryTarget.value = selectedAddress.formatted_address
    this.latitudeTarget.value = selectedAddress.latitude
    this.longitudeTarget.value = selectedAddress.longitude
    this.resultsTarget.innerHTML = ""
  }
}
