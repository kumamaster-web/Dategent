import { Controller } from "@hotwired/stimulus"

// Live character counter for text areas (bio, etc.)
export default class extends Controller {
  static targets = ["input", "count"]

  connect() {
    this.count()
  }

  count() {
    const length = this.inputTarget.value.length
    this.countTarget.textContent = length
  }
}
