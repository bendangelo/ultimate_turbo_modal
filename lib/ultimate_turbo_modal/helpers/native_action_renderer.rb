# frozen_string_literal: true

module UltimateTurboModal
  class NativeActionRenderer
    def initialize(view)
      @view = view
      @output = ActionView::OutputBuffer.new
    end

    def render
      @output.to_s.html_safe
    end

    def cancel(label, _path = nil, **html_attrs)
      render_bridge_button(label, **html_attrs.merge(bridge: "dismiss"))
    end

    def submit(label, form:, **html_attrs)
      render_bridge_button(label, **html_attrs.merge(submit_form: form))
    end

    def button(label, path:, method: :get, **html_attrs)
      render_bridge_button(label, **html_attrs.merge(path: path, method: method))
    end

    private

    def render_bridge_button(label, **data_values)
      data = {controller: "bridge--button"}

      data_values.each do |key, value|
        next if [:class, :data].include?(key)

        data[:"bridge--button-#{key}-value"] = value.to_s
      end

      data[:"bridge--button-title-value"] = label

      html_attrs = data_values.slice(:class, :data) || {}
      html_attrs[:data] = (html_attrs[:data] || {}).merge(data)

      @output.safe_concat(@view.tag.div("", **html_attrs, aria: {hidden: "true"}))
    end
  end
end
