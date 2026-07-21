# frozen_string_literal: true

module UltimateTurboModal::Helpers
  module ViewHelper
    def modal(title: nil, **options, &)
      if native_sheet?
        wrapper_locals = {
          title: title,
          content_div_data: options[:content_div_data]
        }
        render(UltimateTurboModal.configuration.native_sheet_config.wrapper_partial, **wrapper_locals) do
          capture(&)
        end
      else
        render(UltimateTurboModal.new(request:, title: title, **options), &)
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
      builder.render
    end

    def native_sheet?
      UltimateTurboModal.configuration.native_sheet_config.detect.call(self)
    end

    def inside_native_sheet?
      native_sheet?
    end

    def dismiss_button(label = nil, **html_attrs, &block)
      action = native_sheet? ? "click->native-sheet#dismiss" : "click->modal#hide"
      html_attrs[:data] = (html_attrs[:data] || {}).merge(action: action)
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
