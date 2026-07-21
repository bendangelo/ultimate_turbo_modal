# frozen_string_literal: true

module UltimateTurboModal
  class ModalActionRenderer < InlineActionRenderer
    FOOTER_CLASSES = "flex items-center justify-end gap-3"

    def initialize(view)
      super
      @output = ActionView::OutputBuffer.new
    end

    def render
      content = @output.to_s
      return "" if content.empty?

      @view.tag.div(content.html_safe, class: FOOTER_CLASSES)
    end

    def render_footer
      @output.to_s.html_safe
    end
  end
end
