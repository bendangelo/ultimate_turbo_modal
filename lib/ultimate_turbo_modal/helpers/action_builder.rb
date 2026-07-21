# frozen_string_literal: true

module UltimateTurboModal
  class ActionBuilder
    def initialize(view)
      @view = view
      @renderer = resolve_renderer
    end

    def render
      @renderer.render
    end

    # Render the captured actions without the inline/footer wrapper so the
    # modal component can place them inside its own #modal-footer slot.
    def render_footer
      @renderer.respond_to?(:render_footer) ? @renderer.render_footer : render
    end

    def cancel(label, path = nil, **html_attrs)
      @renderer.cancel(label, path, **html_attrs)
    end

    def submit(label, form:, **html_attrs)
      @renderer.submit(label, form: form, **html_attrs)
    end

    def button(label, path:, method: :get, **html_attrs)
      @renderer.button(label, path: path, method: method, **html_attrs)
    end

    private

    def resolve_renderer
      if @view.respond_to?(:native_sheet?) && @view.native_sheet?
        NativeActionRenderer.new(@view)
      elsif @view.respond_to?(:inside_modal?) && @view.inside_modal?
        ModalActionRenderer.new(@view)
      else
        InlineActionRenderer.new(@view)
      end
    end
  end
end
