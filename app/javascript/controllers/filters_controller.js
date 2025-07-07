import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "dateInputs" ]
  
  submit() {
    clearTimeout(this.timeout)
    this.timeout = setTimeout(() => {
      this.element.requestSubmit()
    }, 300)
  }
  
  toggleDateInputs(event) {
    if (event.target.value === "custom") {
      this.dateInputsTarget.classList.remove("hidden")
    } else {
      this.dateInputsTarget.classList.add("hidden")
    }
  }
}