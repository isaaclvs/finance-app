import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateInputs", "form"]
  
  submit(event) {
    // Show loading state
    this.showLoading()
    
    // Submit the form when any filter changes
    this.element.requestSubmit()
  }
  
  showLoading() {
    // Add loading state to turbo frame targets
    const chartsFrame = document.getElementById("dashboard_charts")
    const transactionsFrame = document.getElementById("dashboard_transactions")
    
    if (chartsFrame) {
      chartsFrame.innerHTML = '<div class="flex items-center justify-center py-8"><div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 dark:border-indigo-400"></div><span class="ml-3 text-sm text-gray-600 dark:text-gray-400">Updating charts...</span></div>'
    }
    
    if (transactionsFrame) {
      transactionsFrame.innerHTML = '<div class="flex items-center justify-center py-8"><div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 dark:border-indigo-400"></div><span class="ml-3 text-sm text-gray-600 dark:text-gray-400">Loading transactions...</span></div>'
    }
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
    
    // Show loading state
    this.showLoading()
    
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
    if (this.hasDateInputsTarget) {
      this.dateInputsTarget.classList.add("hidden")
    }
    
    // Submit the clean form
    this.element.requestSubmit()
  }
}
