import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["select", "message"]
  static values = {
    url: String,
    successMessage: String,
    failureMessage: String
  }

  async submit() {
    this.renderMessage("", false)

    try {
      const response = await fetch(this.urlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken()
        },
        body: JSON.stringify({
          rating: { value: this.selectTarget.value }
        })
      })

      const data = await response.json()

      if (response.ok && data.success) {
        this.updateAverage(data.average_rating)
        this.renderMessage(data.message || this.successMessageValue, false)
      } else {
        const errors = (data.errors || []).join(", ")
        this.renderMessage(errors || data.message || this.failureMessageValue, true)
      }
    } catch (_error) {
      this.renderMessage(this.failureMessageValue, true)
    }
  }

  csrfToken() {
    const token = document.querySelector("meta[name='csrf-token']")
    return token ? token.content : ""
  }

  updateAverage(averageRating) {
    const productRow = this.element.closest("li")
    if (!productRow) return

    const averageNode = productRow.querySelector("[data-rating-average-value]")
    if (averageNode) averageNode.textContent = Number(averageRating).toFixed(1)
  }

  renderMessage(text, isError) {
    this.messageTarget.textContent = text
    this.messageTarget.className = `text-sm mt-2 ${isError ? "text-red-600" : "text-green-600"}`
  }
}
