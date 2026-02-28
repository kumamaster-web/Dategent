import { Application } from "@hotwired/stimulus"
import Dialog from '@stimulus-components/dialog'

const application = Application.start()
application.register('dialog', Dialog)
// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }
