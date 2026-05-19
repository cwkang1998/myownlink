import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["copyIcon", "checkIcon", "tooltip"]
  static values = { text: String }

  async copy() {
    await this.writeText(this.textValue)
    this.showCopied()
  }

  async writeText(text) {
    if (navigator.clipboard && window.isSecureContext) {
      await navigator.clipboard.writeText(text)
      return
    }

    const textarea = document.createElement("textarea")
    textarea.value = text
    textarea.setAttribute("readonly", "")
    textarea.style.position = "fixed"
    textarea.style.left = "-9999px"
    document.body.appendChild(textarea)
    textarea.select()
    document.execCommand("copy")
    document.body.removeChild(textarea)
  }

  showCopied() {
    this.copyIconTarget.classList.add("hidden")
    this.checkIconTarget.classList.remove("hidden")
    this.tooltipTarget.classList.remove("opacity-0", "translate-y-1", "pointer-events-none")
    this.tooltipTarget.classList.add("opacity-100", "translate-y-0")

    window.clearTimeout(this.resetTimeout)
    this.resetTimeout = window.setTimeout(() => {
      this.copyIconTarget.classList.remove("hidden")
      this.checkIconTarget.classList.add("hidden")
      this.tooltipTarget.classList.add("opacity-0", "translate-y-1", "pointer-events-none")
      this.tooltipTarget.classList.remove("opacity-100", "translate-y-0")
    }, 1500)
  }
}
