# frozen_string_literal: true

module UltimateTurboModal::Helpers
  module ControllerHelper
    extend ActiveSupport::Concern

    MODAL_FRAME_IDS = %w[modal modal-inner drawer-modal modal-inner-stacked].freeze

    def inside_modal?
      MODAL_FRAME_IDS.include?(request.headers["Turbo-Frame"])
    end

    def native_sheet?
      UltimateTurboModal.configuration.native_sheet_config.detect.call(self)
    end

    def inside_native_sheet?
      native_sheet?
    end

    def hotwire_native_app?
      UltimateTurboModal.configuration.native_app_detect.call(self)
    end

    def native_full_page?
      hotwire_native_app? && !native_sheet?
    end

    included do
      helper_method :inside_modal?
      helper_method :native_sheet?
      helper_method :inside_native_sheet?
      helper_method :hotwire_native_app?
      helper_method :native_full_page?
    end
  end
end
