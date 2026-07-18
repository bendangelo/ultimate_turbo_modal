import { Application } from "@hotwired/stimulus"
import { UltimateTurboModalController } from "ultimate_turbo_modal"

const application = Application.start()
application.register("modal", UltimateTurboModalController)
