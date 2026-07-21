# frozen_string_literal: true

module UltimateTurboModal
  class NativeSheetConfig
    attr_accessor :detect, :action_renderer, :wrapper_partial, :wrapper_controller, :wrapper_selector

    def initialize
      @detect = ->(context) {
        context.respond_to?(:request) &&
          context.request.headers["X-Turbo-Native-Sheet"].present?
      }
      @action_renderer = UltimateTurboModal::NativeActionRenderer
      @wrapper_partial = "ultimate_turbo_modal/native_sheet_wrapper"
      @wrapper_controller = "native-sheet"
      @wrapper_selector = "data-native-sheet-content"
    end
  end
end
