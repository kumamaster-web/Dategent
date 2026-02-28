import { Controller } from "@hotwired/stimulus"

// Manages collapsible transcript stage panels in the match show view.
// The last panel (most recent stage) starts expanded; others start collapsed.
export default class extends Controller {
  static targets = ["button", "panel", "chevron"]

  toggle(event) {
    const button = event.currentTarget
    const index = parseInt(button.dataset.index)

    const panel = this.panelTargets[index]
    const chevron = this.chevronTargets[index]

    if (!panel || !chevron) return

    const isHidden = panel.classList.contains("hidden")

    if (isHidden) {
      panel.classList.remove("hidden")
      chevron.classList.add("rotate-180")
    } else {
      panel.classList.add("hidden")
      chevron.classList.remove("rotate-180")
    }
  }

  // On connect, ensure the last panel's chevron is rotated (it starts expanded)
  connect() {
    const lastIndex = this.panelTargets.length - 1
    if (lastIndex >= 0 && this.chevronTargets[lastIndex]) {
      this.chevronTargets[lastIndex].classList.add("rotate-180")
    }
  }
}
