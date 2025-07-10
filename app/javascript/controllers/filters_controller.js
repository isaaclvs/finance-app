import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateInputs"]
  
  submit(event) {
    // Submit the form when any filter changes
    this.element.requestSubmit()
  }
  
  toggleDateInputs(event) {
    // Show/hide custom date inputs based on period selection
    const periodValue = event.target.value
    
    if (periodValue === "custom") {
      this.dateInputsTarget.classList.remove("hidden")
    } else {
      this.dateInputsTarget.classList.add("hidden")
    }
  }
}
