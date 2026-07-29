# frozen_string_literal: true

module UltimateTurboModal
  class NativeHeaderActionRenderer
    DEFAULT_ICON = "check"
    DEFAULT_POSITION = "right"

    attr_reader :builder

    def initialize(builder)
      @builder = builder
      @view = builder.view
      @output = ActionView::OutputBuffer.new
    end

    def render
      @output.to_s.html_safe
    end

    def render_footer
      render
    end

    def cancel(_label, _path = nil, **_html_attrs)
      return "" if @builder.configuration.hide_cancel_in_native_sheets
      nil
    end

    def submit(label, form:, icon: nil, **_html_attrs)
      emit_header_action(label, icon: icon, submit_form: form, **_html_attrs)
    end

    def button(label, path:, method: :get, icon: nil, **_html_attrs)
      emit_header_action(label, icon: icon, path: path, method: method, **_html_attrs)
    end

    private

    def emit_header_action(label, icon: nil, path: nil, method: "get", submit_form: nil, **html_attrs)
      data_values = html_attrs.dup
      payload = {
        title: sheet_title,
        overflow_items: [],
        primary_action: {
          key: data_values.delete(:name) || "primary",
          label: label,
          icon: icon || DEFAULT_ICON,
          position: DEFAULT_POSITION,
          method: method.to_s,
          path: path,
          submit_form: submit_form,
          bridge: nil
        }.compact
      }.compact

      div_attrs = data_values.slice(:class, :data) || {}
      div_attrs[:data] = (div_attrs[:data] || {}).merge(
        controller: "bridge--header",
        "bridge--header-payload-value": payload.to_json
      )

      @output.safe_concat(
        @view.tag.div("", **div_attrs, aria: { hidden: "true" })
      )
    end

    def sheet_title
      return @view.content_for(:title).to_s if @view.respond_to?(:content_for)
      ""
    end
  end
end
