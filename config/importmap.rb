# Pin npm packages by running ./bin/importmap
pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
# pin "@hotwired/stimulus-importmap-autoloader", to: "stimulus-importmap-autoloader.js"

# Application-specific
pin "stimulus-autocomplete", to: "//ga.jspm.io/npm:stimulus-autocomplete@3.0.2/src/autocomplete.js"
pin "lodash/debounce", to: "//cdn.skypack.dev/lodash.debounce"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "application", to: "application.js"