import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  toggle() {
    const menu = this.menuTarget
    if (menu.style.display === "none" || menu.style.display === "") {
      menu.style.display = "block"
    } else {
      menu.style.display = "none"
    }
  }
}