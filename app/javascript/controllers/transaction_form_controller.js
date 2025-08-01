import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amountInput", "form", "submitButton"]
  static values = { 
    minAmount: Number,
    maxAmount: Number 
  }
  
  connect() {
    this.updateAmountColor()
    this.#setupValidation()
    this.minAmountValue = this.minAmountValue || 0.01
    this.maxAmountValue = this.maxAmountValue || 999999.99
  }
  
  updateAmountColor() {
    const selectedType = this.element.querySelector('input[name="transaction[transaction_type]"]:checked')
    
    if (selectedType) {
      if (selectedType.value === "income") {
        this.amountInputTarget.classList.remove("text-red-600", "dark:text-red-400")
        this.amountInputTarget.classList.add("text-green-600", "dark:text-green-400")
      } else {
        this.amountInputTarget.classList.remove("text-green-600", "dark:text-green-400")
        this.amountInputTarget.classList.add("text-red-600", "dark:text-red-400")
      }
    }
  }
  
  validateAmount() {
    const amount = parseFloat(this.amountInputTarget.value)
    const isValid = !isNaN(amount) && amount >= this.minAmountValue && amount <= this.maxAmountValue
    
    this.#toggleFieldValidation(this.amountInputTarget, isValid)
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
    
    if (this.hasAmountInputTarget) {
      this.amountInputTarget.addEventListener('input', this.validateAmount.bind(this))
      this.amountInputTarget.addEventListener('blur', this.validateAmount.bind(this))
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
    
    if (this.hasAmountInputTarget) {
      const amount = parseFloat(this.amountInputTarget.value)
      const amountValid = !isNaN(amount) && amount >= this.minAmountValue && amount <= this.maxAmountValue
      return allFieldsValid && amountValid
    }
    
    return allFieldsValid
  }
}