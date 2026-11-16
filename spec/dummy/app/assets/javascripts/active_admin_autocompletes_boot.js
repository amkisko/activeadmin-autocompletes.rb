import "active_admin"
import { Application } from "@hotwired/stimulus"
import FilterAutocompleteController from "controllers/activeadmin_autocompletes/filter_autocomplete_controller"

const application = Application.start()
application.register(
  "activeadmin-autocompletes--filter-autocomplete",
  FilterAutocompleteController
)
