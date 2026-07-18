# frozen_string_literal: true

module UltimateTurboModal
  class ModalActionRenderer < InlineActionRenderer
    FOOTER_CLASSES = "sticky bottom-0 left-0 right-0 flex items-center justify-end gap-2 p-4 border-t border-slate-200 bg-white"

    def initialize(view)
      super
      @output = ActionView::OutputBuffer.new
    end

    def render
      content = @output.to_s
      return "" if content.empty?

      @view.tag.div(content.html_safe, class: FOOTER_CLASSES)
    end

    private

    def render_link(label, path, **attrs)
      @output.safe_concat(@view.link_to(label, path, **attrs))
    end

    def render_button(label, **attrs)
      @output.safe_concat(@view.tag.button(label, **attrs))
    end

    def render_form_button(label, path, method:, **attrs)
      form_attrs = {method: method.to_s, action: path, class: "inline"}
      button_attrs = attrs.except(:form)
      @output.safe_concat(@view.form_with(**form_attrs) do
        @view.tag.button(label, **button_attrs)
      end)
    end
  end
end
