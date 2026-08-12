import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    closeOnSubmitSuccess: { type: Boolean, default: true }
  }

  dismiss() {
    window.history.back()
  }

  // Dismiss the sheet after a successful form submission inside it.
  // Mirrors modal_controller#submitEnd so native sheets close on save the
  // same way web modals/drawers do. Redirect responses are left to the
  // SDK/navigation to handle (e.g. recede_historical_location pops the sheet).
  submitEnd(e) {
    if (!this.closeOnSubmitSuccessValue || !e.detail.success) return
    if (e.target.closest("form[data-modal-ignore-submit]")) return

    const response = e.detail.fetchResponse?.response
    if (response?.redirected) return

    this.dismiss()
  }
}
