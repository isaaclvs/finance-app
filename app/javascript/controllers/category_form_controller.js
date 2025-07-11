import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["nameInput", "colorInput", "submitButton"]
  
  connect() {
    this.#setupValidation()
  }
  
  validateName(event) {
    const field = event.target
    const isValid = field.value.trim().length >= 2
    
    this.#toggleFieldValidation(field, isValid)
    this.#updateSubmitButton()
    
    return isValid
  }
  
  validateColor(event) {
    const field = event.target
    const colorPattern = /^#[0-9A-F]{6}$/i
    const isValid = colorPattern.test(field.value)
    
    this.#toggleFieldValidation(field, isValid)
    this.#updateSubmitButton()
    
    return isValid
  }
  
  validateRequired(event) {
    const field = event.target
    const isValid = field.value.trim() !== ""
    
    this.#toggleFieldValidation(field, isValid)
    this.#updateSubmitButton()
    
    return isValid
  }
  
  #setupValidation() {
    const requiredFields = this.element.querySelectorAll('[required]')
    requiredFields.forEach(field => {
      field.addEventListener('blur', this.validateRequired.bind(this))
      field.addEventListener('input', this.#clearValidationState.bind(this))
    })
    
    if (this.hasNameInputTarget) {
      this.nameInputTarget.addEventListener('input', this.validateName.bind(this))
      this.nameInputTarget.addEventListener('blur', this.validateName.bind(this))
    }
    
    if (this.hasColorInputTarget) {
      this.colorInputTarget.addEventListener('input', this.validateColor.bind(this))
      this.colorInputTarget.addEventListener('blur', this.validateColor.bind(this))
    }
  }
  
  #toggleFieldValidation(field, isValid) {
    const errorClasses = ['border-red-300', 'dark:border-red-600', 'text-red-900', 'dark:text-red-300']
    const validClasses = ['border-green-300', 'dark:border-green-600']
    const normalClasses = ['border-gray-300', 'dark:border-gray-600']
    
    field.classList.remove(...errorClasses, ...validClasses)
    
    if (isValid === false) {
      field.classList.add(...errorClasses)
    } else if (isValid === true && field.value.trim() !== "") {
      field.classList.add(...validClasses)
    } else {
      field.classList.add(...normalClasses)
    }
  }
  
  #clearValidationState(event) {
    const field = event.target
    const errorClasses = ['border-red-300', 'dark:border-red-600', 'text-red-900', 'dark:text-red-300']
    const validClasses = ['border-green-300', 'dark:border-green-600']
    
    field.classList.remove(...errorClasses, ...validClasses)
    field.classList.add('border-gray-300', 'dark:border-gray-600')
  }
  
  #updateSubmitButton() {
    if (!this.hasSubmitButtonTarget) return
    
    const isFormValid = this.#isFormValid()
    this.submitButtonTarget.disabled = !isFormValid
    
    if (isFormValid) {
      this.submitButtonTarget.classList.remove('opacity-50', 'cursor-not-allowed')
    } else {
      this.submitButtonTarget.classList.add('opacity-50', 'cursor-not-allowed')
    }
  }
  
  #isFormValid() {
    const requiredFields = this.element.querySelectorAll('[required]')
    const allFieldsValid = Array.from(requiredFields).every(field => field.value.trim() !== "")
    
    // Validate color format if present
    if (this.hasColorInputTarget) {
      const colorPattern = /^#[0-9A-F]{6}$/i
      const colorValid = colorPattern.test(this.colorInputTarget.value)
      return allFieldsValid && colorValid
    }
    
    return allFieldsValid
  }
}