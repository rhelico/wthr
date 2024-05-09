// Import and register all your controllers from the importmap under controllers/*

import { application } from "controllers/application"
import { Application } from "@hotwired/stimulus"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// application specific

// for autocomplete
import AddressAutocompleteController from "./address_autocomplete_controller"
application.register("address-autocomplete", AddressAutocompleteController)
