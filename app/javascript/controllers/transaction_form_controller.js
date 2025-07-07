import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "amountInput" ]
  
  connect() {
    this.updateAmountColor()
  }
  
  updateAmountColor() {
    const selectedType = this.element.querySelector('input[name="transaction[transaction_type]"]:checked')
    
    if (selectedType) {
      if (selectedType.value === "income") {
        this.amountInputTarget.classList.remove("text-red-600")
        this.amountInputTarget.classList.add("text-green-600")
      } else {
        this.amountInputTarget.classList.remove("text-green-600")
        this.amountInputTarget.classList.add("text-red-600")
      }
    }
  }
}