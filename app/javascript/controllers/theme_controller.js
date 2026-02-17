import { Controller } from "@hotwired/stimulus"

// Handles dark/light mode toggle
// Persists preference to localStorage
export default class extends Controller {
  connect() {
    this.applyTheme()
  }

  toggle() {
    const isDark = document.documentElement.classList.contains("dark")
    if (isDark) {
      document.documentElement.classList.remove("dark")
      localStorage.setItem("theme", "light")
    } else {
      document.documentElement.classList.add("dark")
      localStorage.setItem("theme", "dark")
    }
  }

  applyTheme() {
    const stored = localStorage.getItem("theme")
    if (stored === "dark" || (!stored && window.matchMedia("(prefers-color-scheme: dark)").matches)) {
      document.documentElement.classList.add("dark")
    } else {
      document.documentElement.classList.remove("dark")
    }
  }
}
