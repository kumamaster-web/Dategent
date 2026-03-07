import { Controller } from "@hotwired/stimulus"

// Handles tabbed match filtering and card pagination/swiping on the dashboard.
// Tabs switch between match status groups; swipe or dot-click navigates cards.
export default class extends Controller {
  static targets = ["tab", "panel", "card", "dot"]
  static values = { active: { type: String, default: "proposed" } }

  connect() {
    this.currentIndex = 0
    this.showTab(this.activeValue)

    // Touch swipe support
    this.touchStartX = 0
    this.element.addEventListener("touchstart", (e) => { this.touchStartX = e.touches[0].clientX }, { passive: true })
    this.element.addEventListener("touchend", (e) => {
      const diff = this.touchStartX - e.changedTouches[0].clientX
      if (Math.abs(diff) > 50) { diff > 0 ? this.next() : this.prev() }
    }, { passive: true })
  }

  switch(event) {
    event.preventDefault()
    const tab = event.currentTarget.dataset.tab
    this.activeValue = tab
    this.showTab(tab)
  }

  // Class lists for pill-style active/inactive tabs (matches /matches index design)
  static activeClasses = ["bg-indigo-600", "text-white", "border-transparent"]
  static inactiveClasses = ["bg-white", "dark:bg-gray-700", "text-gray-600", "dark:text-gray-400", "border", "border-gray-200", "dark:border-gray-600"]

  showTab(tab) {
    // Update tab pill styles
    this.tabTargets.forEach((el) => {
      const active = el.dataset.tab === tab
      this.constructor.activeClasses.forEach((c) => el.classList.toggle(c, active))
      this.constructor.inactiveClasses.forEach((c) => el.classList.toggle(c, !active))
    })

    // Show/hide panels
    this.panelTargets.forEach((panel) => {
      panel.classList.toggle("hidden", panel.dataset.tab !== tab)
    })

    // Reset to first card in active panel
    this.currentIndex = 0
    this.updateCards()
  }

  prev() {
    if (this.currentIndex > 0) {
      this.currentIndex--
      this.updateCards()
    }
  }

  next() {
    const visibleCards = this.visibleCards()
    if (this.currentIndex < visibleCards.length - 1) {
      this.currentIndex++
      this.updateCards()
    }
  }

  goToCard(event) {
    this.currentIndex = parseInt(event.currentTarget.dataset.index, 10)
    this.updateCards()
  }

  updateCards() {
    const visibleCards = this.visibleCards()
    const visibleDots = this.visibleDots()

    visibleCards.forEach((card, i) => {
      card.classList.toggle("hidden", i !== this.currentIndex)
    })

    const activeColor = "#9333ea"
    const inactiveColor = "#e9d5ff"

    visibleDots.forEach((dot, i) => {
      dot.style.backgroundColor = (i === this.currentIndex) ? activeColor : inactiveColor
    })
  }

  visibleCards() {
    const activePanel = this.panelTargets.find((p) => !p.classList.contains("hidden"))
    if (!activePanel) return []
    return this.cardTargets.filter((c) => activePanel.contains(c))
  }

  visibleDots() {
    const activePanel = this.panelTargets.find((p) => !p.classList.contains("hidden"))
    if (!activePanel) return []
    return this.dotTargets.filter((d) => activePanel.contains(d))
  }
}
