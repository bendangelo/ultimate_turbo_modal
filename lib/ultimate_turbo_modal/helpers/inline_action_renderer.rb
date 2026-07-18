# frozen_string_literal: true

module UltimateTurboModal
  class InlineActionRenderer
    BUTTON_BASE = "px-4 py-2 rounded-md text-sm font-medium transition-colors focus:outline-none focus:ring-2 focus:ring-offset-2"

    def initialize(view)
      @view = view
      @output = ActionView::OutputBuffer.new
    end

    def render
      @output.to_s
    end

    def cancel(label, path = nil, **html_attrs)
      if path
        render_link(label, path, **html_attrs.merge(class: cancel_classes(html_attrs[:class])))
      else
        render_button(label, type: "button", **html_attrs.merge(class: cancel_classes(html_attrs[:class])))
      end
    end

    def submit(label, form:, **html_attrs)
      render_button(label, type: "submit", form: form, **html_attrs.merge(class: primary_classes(html_attrs[:class])))
    end

    def button(label, path:, method: :get, **html_attrs)
      if method.to_sym == :get
        render_link(label, path, **html_attrs.merge(class: secondary_classes(html_attrs[:class])))
      else
        render_form_button(label, path, method: method, **html_attrs.merge(class: secondary_classes(html_attrs[:class])))
      end
    end

    private

    def render_link(label, path, **attrs)
      attrs[:data] ||= {}
      attrs[:data][:turbo_method] = attrs.delete(:method)&.to_s if attrs.key?(:method)
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

    def primary_classes(extra)
      [BUTTON_BASE, "bg-blue-600 text-white hover:bg-blue-700 focus:ring-blue-500", extra].compact_blank.join(" ")
    end

    def secondary_classes(extra)
      [BUTTON_BASE, "bg-slate-100 text-slate-700 hover:bg-slate-200 focus:ring-slate-500", extra].compact_blank.join(" ")
    end

    def cancel_classes(extra)
      [BUTTON_BASE, "bg-transparent text-slate-600 hover:text-slate-800 hover:bg-slate-100", extra].compact_blank.join(" ")
    end
  end
end
