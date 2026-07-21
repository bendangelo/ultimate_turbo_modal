# frozen_string_literal: true

module UltimateTurboModal
  class NativeSheetConfig
    attr_accessor :detect, :action_renderer, :wrapper_partial, :wrapper_controller, :wrapper_selector

    def initialize
      @detect = ->(context) {
        if context.respond_to?(:request)
          headers = context.request.headers
          return true if headers["X-Turbo-Native-Sheet"].present?
          ua = headers["User-Agent"].to_s
          return true if ua.match?(/;\s*Native-Sheet\b/)
        end
        false
      }
      @action_renderer = UltimateTurboModal::NativeActionRenderer
      @wrapper_partial = "ultimate_turbo_modal/native_sheet_wrapper"
      @wrapper_controller = "native-sheet"
      @wrapper_selector = "data-native-sheet-content"
    end
  end
end
