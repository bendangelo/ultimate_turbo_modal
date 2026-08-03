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
      @renderer.respond_to?(:render_footer) ? @renderer.render_footer : render
    end

    def cancel(label, path = nil, visible_in: nil, **html_attrs)
      render_if_visible(visible_in) { @renderer.cancel(label, path, **html_attrs) }
    end

    def submit(label, form: nil, primary: false, overflow: false, visible_in: nil, **html_attrs)
      form ||= @view.try(:single_form_id)
      render_if_visible(visible_in) { @renderer.submit(label, form: form, primary: primary, overflow: overflow, **html_attrs) }
    end

    def button(label, path:, method: :get, primary: false, overflow: false, visible_in: nil, **html_attrs)
      render_if_visible(visible_in) { @renderer.button(label, path: path, method: method, primary: primary, overflow: overflow, **html_attrs) }
    end

    def overflow_menu(items, icon: nil)
      @renderer.overflow_menu(items, icon: icon) if @renderer.respond_to?(:overflow_menu)
    end

    def native_sheet?
      @view.respond_to?(:native_sheet?) && @view.native_sheet?
    end

    def inside_modal?
      @view.respond_to?(:inside_modal?) && @view.inside_modal?
    end

    def native_full_page?
      hotwire_native_app? && !native_sheet?
    end

    def hotwire_native_app?
      @view.respond_to?(:hotwire_native_app?) && @view.hotwire_native_app?
    end

    private

    def resolve_renderer
      if native_sheet? || native_full_page?
        @configuration.native_sheet_config.action_renderer.new(self)
      elsif inside_modal?
        ModalActionRenderer.new(self)
      else
        InlineActionRenderer.new(self)
      end
    end

    def render_if_visible(visible_in)
      if visible_in
        visible_in = Array(visible_in)
        return "" unless visible_in.include?(current_context)
      end
      yield
    end

    def current_context
      if native_full_page?
        :native_full_page
      elsif native_sheet?
        :native_sheet
      elsif inside_modal?
        :browser_modal
      else
        :browser_full_page
      end
    end
  end
end
