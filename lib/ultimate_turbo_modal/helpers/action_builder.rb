# frozen_string_literal: true

module UltimateTurboModal
  class ActionBuilder
    attr_reader :view, :configuration, :renderer

    def initialize(view)
      @view = view
      @configuration = UltimateTurboModal.configuration
      @renderer = resolve_renderer
    end

    def render
      @renderer.render
    end

    # Render the captured actions without the inline/footer wrapper so the
    # modal component can place them inside its own #modal-footer slot.
    def render_footer
      @renderer.render_footer
    end

    def cancel(label, path = nil, **html_attrs)
      @renderer.cancel(label, path, **html_attrs)
    end

    def submit(label, form: nil, **html_attrs)
      form ||= @view.try(:single_form_id)
      @renderer.submit(label, form: form, **html_attrs)
    end

    def button(label, path:, method: :get, **html_attrs)
      @renderer.button(label, path: path, method: method, **html_attrs)
    end

    def overflow_menu(items, icon: nil)
      @renderer.overflow_menu(items, icon: icon) if @renderer.respond_to?(:overflow_menu)
    end

    private

    def resolve_renderer
      if @view.respond_to?(:native_sheet?) && @view.native_sheet?
        @configuration.native_sheet_config.action_renderer.new(self)
      else
        ModalActionRenderer.new(self)
      end
    end
  end
end
