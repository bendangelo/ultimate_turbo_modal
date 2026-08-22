# frozen_string_literal: true

module UltimateTurboModal::Helpers
  module ViewHelper
    def modal(title: nil, **options, &)
      @ultimate_turbo_modal_component = UltimateTurboModal.new(request:, title: title, **options)
      begin
        render(@ultimate_turbo_modal_component, &)
      ensure
        @ultimate_turbo_modal_component = nil
      end
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

      if @ultimate_turbo_modal_component && inside_modal?
        @ultimate_turbo_modal_component.actions(builder)
        ""
      else
        builder.render
      end
    end

    def dismiss_button(label = nil, **html_attrs, &block)
      html_attrs[:data] = (html_attrs[:data] || {}).merge(action: "click->modal#hide")
      if block
        tag.button(type: "button", **html_attrs, &block)
      else
        tag.button(label, type: "button", **html_attrs)
      end
    end

    def inside_modal?
      frame = request&.headers&.[]("Turbo-Frame")
      UltimateTurboModal::Helpers::ControllerHelper::MODAL_FRAME_IDS.include?(frame)
    end
  end
end