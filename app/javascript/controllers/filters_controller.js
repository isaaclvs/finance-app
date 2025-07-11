import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateInputs", "form"]
  
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
  
  clearForm(event) {
    event.preventDefault()
    
    // Reset all form fields to their default state
    this.element.reset()
    
    // Explicitly reset selects to first option (empty value)
    const selects = this.element.querySelectorAll('select')
    selects.forEach(select => {
      select.selectedIndex = 0
    })
    
    // Reset text inputs
    const textInputs = this.element.querySelectorAll('input[type="text"], input[type="search"]')
    textInputs.forEach(input => {
      input.value = ''
    })
    
    // Reset date inputs
    const dateInputs = this.element.querySelectorAll('input[type="date"]')
    dateInputs.forEach(input => {
      input.value = ''
    })
    
    // Hide custom date inputs
    this.dateInputsTarget.classList.add("hidden")
    
    // Submit the clean form
    this.element.requestSubmit()
  }
}
