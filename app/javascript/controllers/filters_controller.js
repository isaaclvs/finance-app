import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dateInputs"]
  
  connect() {
    this.element.addEventListener('keydown', (event) => {
      if (event.key === 'Enter') {
        event.preventDefault()
      }
    })
    
    document.addEventListener('turbo:frame-load', this.#removeLoading.bind(this))
    document.addEventListener('turbo:stream-response', this.#removeLoading.bind(this))
  }
  
  disconnect() {
    document.removeEventListener('turbo:frame-load', this.#removeLoading.bind(this))
    document.removeEventListener('turbo:stream-response', this.#removeLoading.bind(this))
  }
  
  submit(event) {
    if (event.type === 'input') {
      this.#submitWithDebounce()
    } else {
      this.#showLoading()
      this.element.requestSubmit()
    }
  }
  
  toggleDateInputs(event) {
    const periodValue = event.target.value
    
    if (periodValue === "custom") {
      this.dateInputsTarget.classList.remove("hidden")
    } else {
      this.dateInputsTarget.classList.add("hidden")
    }
  }
  
  clearForm(event) {
    event.preventDefault()
    
    this.#showLoading()
    this.element.reset()
    
    this.element.querySelectorAll('select').forEach(select => {
      select.selectedIndex = 0
    })
    
    this.element.querySelectorAll('input[type="text"], input[type="search"], input[type="date"]').forEach(input => {
      input.value = ''
    })
    
    if (this.hasDateInputsTarget) {
      this.dateInputsTarget.classList.add("hidden")
    }
    
    this.element.requestSubmit()
  }
  
  #submitWithDebounce() {
    clearTimeout(this.timeout)
    
    this.timeout = setTimeout(() => {
      this.#showLoading()
      
      setTimeout(() => {
        this.#removeLoading()
      }, 2000)
      
      this.element.requestSubmit()
    }, 300)
  }
  
  #showLoading() {
    const chartsFrame = document.getElementById("dashboard_charts")
    const transactionsFrame = document.getElementById("dashboard_transactions")
    const goalsFrame = document.getElementById("goals_grid")
    
    if (chartsFrame) {
      chartsFrame.innerHTML = this.#loadingSpinner("Updating charts...")
    }
    
    if (transactionsFrame) {
      transactionsFrame.innerHTML = this.#loadingSpinner("Loading transactions...")
    }
    
    if (goalsFrame) {
      goalsFrame.classList.add('opacity-50')
      goalsFrame.style.pointerEvents = 'none'
    }
  }
  
  #removeLoading() {
    const goalsFrame = document.getElementById("goals_grid")
    if (goalsFrame) {
      goalsFrame.classList.remove('opacity-50')
      goalsFrame.style.pointerEvents = 'auto'
    }
  }
  
  #loadingSpinner(message) {
    return `<div class="flex items-center justify-center py-8">
              <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-indigo-600 dark:border-indigo-400"></div>
              <span class="ml-3 text-sm text-gray-600 dark:text-gray-400">${message}</span>
            </div>`
  }
}
