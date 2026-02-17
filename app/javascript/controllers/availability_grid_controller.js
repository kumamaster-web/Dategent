import { Controller } from "@hotwired/stimulus"

// Interactive weekly availability grid with 30-minute granularity.
// Stores selections as JSON in a hidden input.
//
// Schema (designed for iCal / Google Calendar interop):
// {
//   "monday":    ["09:00", "09:30", "10:00"],
//   "tuesday":   ["18:00", "18:30", "19:00", "19:30"],
//   ...
// }
//
// Times are 24h format (HH:MM), stored relative to the user's selected timezone.
// Conversion to external calendar formats:
//   - Each day + contiguous slot range → iCal VEVENT with RRULE:FREQ=WEEKLY;BYDAY=MO
//   - Timezone field → VTIMEZONE / Google Calendar timeZone property
//   - Contiguous 30-min slots merge into single free/busy blocks
//   - Compatible with Google Calendar FreeBusy API, Apple Calendar, Outlook
//
// Supports click, tap, and click-drag to select/deselect ranges.
export default class extends Controller {
  static targets = ["cell", "hiddenInput"]
  static values = {
    schedule: { type: Object, default: {} }
  }

  connect() {
    this.isDragging = false
    this.dragMode = null // "select" or "deselect"
    this.syncFromHidden()
    this.render()

    // Prevent text selection while dragging
    this.element.addEventListener("selectstart", (e) => {
      if (this.isDragging) e.preventDefault()
    })

    // Global mouseup/touchend to end drag
    this._endDrag = this.endDrag.bind(this)
    document.addEventListener("mouseup", this._endDrag)
    document.addEventListener("touchend", this._endDrag)
  }

  disconnect() {
    document.removeEventListener("mouseup", this._endDrag)
    document.removeEventListener("touchend", this._endDrag)
  }

  syncFromHidden() {
    try {
      const val = this.hiddenInputTarget.value
      if (val && val !== "{}") {
        this.scheduleValue = JSON.parse(val)
      }
    } catch (e) {
      this.scheduleValue = {}
    }
  }

  // --- Drag selection (mouse) ---
  startDrag(event) {
    event.preventDefault()
    this.isDragging = true
    const cell = event.currentTarget
    const day = cell.dataset.day
    const slot = cell.dataset.slot
    const isActive = (this.scheduleValue[day] || []).includes(slot)
    this.dragMode = isActive ? "deselect" : "select"
    this.applyToCell(day, slot)
  }

  enterCell(event) {
    if (!this.isDragging) return
    const cell = event.currentTarget
    this.applyToCell(cell.dataset.day, cell.dataset.slot)
  }

  // --- Drag selection (touch) ---
  touchStart(event) {
    const cell = event.currentTarget
    const day = cell.dataset.day
    const slot = cell.dataset.slot
    const isActive = (this.scheduleValue[day] || []).includes(slot)
    this.isDragging = true
    this.dragMode = isActive ? "deselect" : "select"
    this.applyToCell(day, slot)
  }

  touchMove(event) {
    if (!this.isDragging) return
    event.preventDefault()
    const touch = event.touches[0]
    const el = document.elementFromPoint(touch.clientX, touch.clientY)
    if (el && el.dataset.day && el.dataset.slot) {
      this.applyToCell(el.dataset.day, el.dataset.slot)
    }
  }

  endDrag() {
    if (this.isDragging) {
      this.isDragging = false
      this.dragMode = null
      this.save()
    }
  }

  applyToCell(day, slot) {
    const schedule = { ...this.scheduleValue }
    if (!schedule[day]) schedule[day] = []
    const arr = [...schedule[day]]

    if (this.dragMode === "select" && !arr.includes(slot)) {
      arr.push(slot)
    } else if (this.dragMode === "deselect") {
      const idx = arr.indexOf(slot)
      if (idx >= 0) arr.splice(idx, 1)
    }

    schedule[day] = arr
    this.scheduleValue = schedule
    this.render()
  }

  // --- Bulk toggles ---
  toggleDay(event) {
    const day = event.currentTarget.dataset.day
    const schedule = { ...this.scheduleValue }
    const current = schedule[day] || []
    const allSlots = this.getAllSlots()

    schedule[day] = current.length === allSlots.length ? [] : [...allSlots]
    this.scheduleValue = schedule
    this.render()
    this.save()
  }

  toggleSlot(event) {
    const slot = event.currentTarget.dataset.slot
    const days = this.getDays()
    const schedule = { ...this.scheduleValue }
    const allHave = days.every(d => (schedule[d] || []).includes(slot))

    days.forEach(day => {
      if (!schedule[day]) schedule[day] = []
      const arr = [...schedule[day]]
      const idx = arr.indexOf(slot)
      if (allHave) {
        if (idx >= 0) arr.splice(idx, 1)
      } else {
        if (idx < 0) arr.push(slot)
      }
      schedule[day] = arr
    })

    this.scheduleValue = schedule
    this.render()
    this.save()
  }

  clearAll() {
    this.scheduleValue = {}
    this.render()
    this.save()
  }

  // --- Helpers ---
  save() {
    this.hiddenInputTarget.value = JSON.stringify(this.scheduleValue)
  }

  getDays() {
    return ["monday", "tuesday", "wednesday", "thursday", "friday", "saturday", "sunday"]
  }

  getAllSlots() {
    const slots = []
    for (let h = 7; h <= 23; h++) {
      slots.push(`${String(h).padStart(2, "0")}:00`)
      if (h < 23) slots.push(`${String(h).padStart(2, "0")}:30`)
    }
    return slots
  }

  render() {
    this.cellTargets.forEach(cell => {
      const day = cell.dataset.day
      const slot = cell.dataset.slot
      const isActive = (this.scheduleValue[day] || []).includes(slot)

      if (isActive) {
        cell.className = "h-6 sm:h-7 min-w-[2.25rem] rounded-sm cursor-pointer transition-colors bg-indigo-500 dark:bg-indigo-500 ring-1 ring-indigo-600/50 dark:ring-indigo-400/50"
      } else {
        cell.className = "h-6 sm:h-7 min-w-[2.25rem] rounded-sm cursor-pointer transition-colors bg-gray-50 dark:bg-gray-700/50 hover:bg-gray-200 dark:hover:bg-gray-600 ring-1 ring-gray-200 dark:ring-gray-600"
      }
    })
  }
}
