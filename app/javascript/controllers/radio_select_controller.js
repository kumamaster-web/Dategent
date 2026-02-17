import { Controller } from "@hotwired/stimulus"

// Handles visual selection state for radio button card groups.
// Highlights the selected card and deselects others on click.
export default class extends Controller {
  static classes = ["selected", "unselected"]
  static targets = ["card"]

  connect() {
    // Set initial state based on which radio is checked
    this.updateSelection()
  }

  select(event) {
    // Find the radio input inside the clicked card and check it
    const card = event.currentTarget
    const radio = card.querySelector("input[type='radio']")
    if (radio) {
      radio.checked = true
    }
    this.updateSelection()
  }

  updateSelection() {
    this.cardTargets.forEach((card) => {
      const radio = card.querySelector("input[type='radio']")
      const icon = card.querySelector("[data-role='icon']")
      if (radio && radio.checked) {
        card.className = this.selectedCardClasses()
        if (icon) icon.className = this.selectedIconClasses()
      } else {
        card.className = this.unselectedCardClasses()
        if (icon) icon.className = this.unselectedIconClasses()
      }
    })
  }

  selectedCardClasses() {
    return "relative flex items-center gap-3 px-4 py-3 rounded-xl border cursor-pointer transition-all bg-indigo-50 border-indigo-300 ring-2 ring-indigo-500 dark:bg-indigo-900/30 dark:border-indigo-600"
  }

  unselectedCardClasses() {
    return "relative flex items-center gap-3 px-4 py-3 rounded-xl border cursor-pointer transition-all bg-white border-gray-200 hover:border-gray-300 dark:bg-gray-700 dark:border-gray-600 dark:hover:border-gray-500"
  }

  selectedIconClasses() {
    return "w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 bg-indigo-100 dark:bg-indigo-800"
  }

  unselectedIconClasses() {
    return "w-10 h-10 rounded-lg flex items-center justify-center flex-shrink-0 bg-gray-100 dark:bg-gray-600"
  }
}
