import { Controller } from "@hotwired/stimulus"

// Updates a display value when a range slider changes
export default class extends Controller {
  static targets = ["input", "value"]

  connect() {
    this.update()
  }

  update() {
    this.valueTarget.textContent = this.inputTarget.value
  }
}
