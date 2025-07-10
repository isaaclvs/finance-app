import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount"]
  
  connect() {
    this.#highlightUpdate()
  }
  
  #highlightUpdate() {
    this.amountTargets.forEach(target => {
      target.classList.add("balance-updated")
      
      setTimeout(() => {
        target.classList.remove("balance-updated")
      }, 600)
    })
  }
}
