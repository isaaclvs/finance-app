import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "progressForm"]
  static values = { goalId: String }

  connect() {
    // Initialize any needed setup
  }

  openProgressModal(event) {
    if (event) event.preventDefault()
    const goalId = event.currentTarget.dataset.goalId
    const modal = document.getElementById(`update_progress_modal_${goalId}`)
    
    if (modal) {
      modal.classList.remove("hidden")
      document.body.classList.add("overflow-hidden")
      this.#trapFocus(modal)
    }
  }

  closeProgressModal(event) {
    if (event) event.preventDefault()
    const modal = event.currentTarget.closest(".modal")
    
    if (modal) {
      modal.classList.add("hidden")
      document.body.classList.remove("overflow-hidden")
    }
  }

  closeOnOverlay(event) {
    if (event.target === event.currentTarget) {
      this.closeProgressModal(event)
    }
  }

  preventClose(event) {
    event.stopPropagation()
  }

  submitProgress(event) {
    const form = event.currentTarget.closest("form")
    if (form) {
      form.requestSubmit()
      this.closeProgressModal(event)
    }
  }

  #trapFocus(modal) {
    const focusableElements = modal.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    
    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }

    // Handle escape key
    const handleEscape = (event) => {
      if (event.key === "Escape") {
        modal.classList.add("hidden")
        document.body.classList.remove("overflow-hidden")
        document.removeEventListener("keydown", handleEscape)
      }
    }

    document.addEventListener("keydown", handleEscape)
  }
}