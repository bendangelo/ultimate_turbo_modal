# frozen_string_literal: true

module UltimateTurboModal::Helpers
  module ViewHelper
    def modal(**, &)
      render(UltimateTurboModal.new(request:, **), &)
    end

    def drawer(position: nil, size: nil, **options, &block)
      cfg = UltimateTurboModal.configuration.drawer_config
      position = UltimateTurboModal::Base.validate_drawer_position!(position || cfg.position)
      size = UltimateTurboModal::Base.validate_drawer_size!(size || cfg.size)
      modal(drawer_position: position, size: size, **options, &block)
    end

    def actions(&block)
      builder = UltimateTurboModal::ActionBuilder.new(self)
      capture(builder, &block)
      builder.render
    end

    def native_sheet?
      UltimateTurboModal.configuration.native_sheet_config.detect.call(self)
    end

    def inside_modal?
      frame = request&.headers&.[]("Turbo-Frame")
      UltimateTurboModal::Helpers::ControllerHelper::MODAL_FRAME_IDS.include?(frame)
    end
  end
end
