import { Application} from "@hotwired/stimulus"
import { Autocomplete } from "stimulus-autocomplete"
// Start the Stimulus application
const application = Application.start()

// Register the Autocomplete controller
application.register("autocomplete", Autocomplete)

// Debugging options
application.debug = true
window.Stimulus = application

export { application }


