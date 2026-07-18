import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  intercept(event) {
    const method = event.detail.fetchOptions?.method?.toUpperCase()
    if (method && method !== "GET") return

    event.preventDefault()
    window.Turbo?.visit(event.detail.url)
  }
}
