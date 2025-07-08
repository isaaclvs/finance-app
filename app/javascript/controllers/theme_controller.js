import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "icon" ]
  
  connect() {
    // Check for saved theme preference or default to 'light'
    const theme = localStorage.getItem('theme') || 'light'
    
    // Check system preference if no saved preference
    if (!localStorage.getItem('theme')) {
      const systemPrefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches
      if (systemPrefersDark) {
        this.setTheme('dark')
      } else {
        this.setTheme('light')
      }
    } else {
      this.setTheme(theme)
    }
    
    // Listen for system theme changes
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
      if (!localStorage.getItem('theme')) {
        this.setTheme(e.matches ? 'dark' : 'light')
      }
    })
  }
  
  toggle() {
    const currentTheme = document.documentElement.classList.contains('dark') ? 'dark' : 'light'
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark'
    this.setTheme(newTheme)
  }
  
  setTheme(theme) {
    if (theme === 'dark') {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
    
    // Save preference
    localStorage.setItem('theme', theme)
    
    // Update icon
    this.updateIcon(theme)
    
    // Dispatch custom event
    window.dispatchEvent(new CustomEvent('theme-changed', { detail: { theme } }))
  }
  
  updateIcon(theme) {
    if (!this.hasIconTarget) return
    
    if (theme === 'dark') {
      // Show sun icon when in dark mode (to switch to light)
      this.iconTarget.innerHTML = `<path fill-rule="evenodd" d="M10 2a1 1 0 011 1v1a1 1 0 11-2 0V3a1 1 0 011-1zm4 8a4 4 0 11-8 0 4 4 0 018 0zm-.464 4.95l.707.707a1 1 0 001.414-1.414l-.707-.707a1 1 0 00-1.414 1.414zm2.12-10.607a1 1 0 010 1.414l-.706.707a1 1 0 11-1.414-1.414l.707-.707a1 1 0 011.414 0zM17 11a1 1 0 100-2h-1a1 1 0 100 2h1zm-7 4a1 1 0 011 1v1a1 1 0 11-2 0v-1a1 1 0 011-1zM5.05 6.464A1 1 0 106.465 5.05l-.708-.707a1 1 0 00-1.414 1.414l.707.707zm1.414 8.486l-.707.707a1 1 0 01-1.414-1.414l.707-.707a1 1 0 011.414 1.414zM4 11a1 1 0 100-2H3a1 1 0 000 2h1z" clip-rule="evenodd"></path>`
    } else {
      // Show moon icon when in light mode (to switch to dark)
      this.iconTarget.innerHTML = `<path d="M17.293 13.293A8 8 0 016.707 2.707a8.001 8.001 0 1010.586 10.586z"></path>`
    }
  }
}