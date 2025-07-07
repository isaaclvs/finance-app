import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "hexInput", "preview" ]
  
  connect() {
    this.updatePreview()
  }
  
  updateColor(event) {
    const hex = event.target.value
    if (this.#isValidHex(hex)) {
      this.element.querySelector('input[type="color"]').value = hex
      this.updatePreview()
    }
  }
  
  updatePreview() {
    const colorInput = this.element.querySelector('input[type="color"]')
    const hexValue = colorInput.value
    
    this.hexInputTarget.value = hexValue.toUpperCase()
    this.previewTarget.style.backgroundColor = hexValue
  }
  
  #isValidHex(hex) {
    return /^#[0-9A-F]{6}$/i.test(hex)
  }
}