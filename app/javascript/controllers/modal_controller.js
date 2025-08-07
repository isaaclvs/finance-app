import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["backdrop", "dialog"]
  
  connect() {
    this.#trapFocus()
    this.#addKeyListener()
    document.body.classList.add("overflow-hidden")
  }
  
  disconnect() {
    document.body.classList.remove("overflow-hidden")
    document.removeEventListener("keydown", this.#handleKeydown)
  }
  
  close(event) {
    if (event) event.preventDefault()
    this.element.innerHTML = ""
    this.element.removeAttribute("src")
    this.element.removeAttribute("complete")
  }
  
  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }
  
  preventClose(event) {
    event.stopPropagation()
  }
  
  #handleKeydown = (event) => {
    if (event.key === "Escape") {
      this.close()
    }
  }
  
  #addKeyListener() {
    document.addEventListener("keydown", this.#handleKeydown)
  }
  
  #trapFocus() {
    const focusableElements = this.element.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    )
    
    if (focusableElements.length > 0) {
      focusableElements[0].focus()
    }
  }
}