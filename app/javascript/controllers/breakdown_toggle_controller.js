import { Controller } from "@hotwired/stimulus"

// Toggles visibility of LLM commentary panels beneath each
// compatibility breakdown category card.
export default class extends Controller {
  static targets = ["trigger", "panel", "chevron"]

  toggle(event) {
    const trigger = event.currentTarget
    const idx = this.triggerTargets.indexOf(trigger)
    if (idx === -1) return

    const panel = this.panelTargets[idx]
    const chevron = this.chevronTargets[idx]
    if (!panel) return

    const isHidden = panel.classList.contains("hidden")
    panel.classList.toggle("hidden", !isHidden)
    if (chevron) {
      chevron.classList.toggle("rotate-180", isHidden)
    }
  }
}
