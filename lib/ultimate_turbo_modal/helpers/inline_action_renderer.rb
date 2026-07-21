# frozen_string_literal: true

module UltimateTurboModal
  class InlineActionRenderer
    DEFAULT_PRIMARY_CLASSES   = "btn btn-primary"
    DEFAULT_SECONDARY_CLASSES = "btn btn-secondary"
    DEFAULT_DANGER_CLASSES    = "btn btn-danger"

    def initialize(view)
      @view = view
      @output = ActionView::OutputBuffer.new
    end

    def render
      @output.to_s
    end

    def cancel(label, path = nil, **html_attrs)
      html_attrs[:class] = DEFAULT_SECONDARY_CLASSES if html_attrs[:class].blank?
      if path
        render_link(label, path, **html_attrs)
      else
        render_button(label, type: "button", **html_attrs)
      end
    end

    def submit(label, form:, primary: false, danger: false, **html_attrs)
      if html_attrs[:class].blank?
        html_attrs[:class] = danger ? DEFAULT_DANGER_CLASSES : DEFAULT_PRIMARY_CLASSES
      end
      render_button(label, type: "submit", form: form, **html_attrs)
    end

    def button(label, path:, method: :get, primary: false, danger: false, **html_attrs)
      if html_attrs[:class].blank?
        html_attrs[:class] = DEFAULT_DANGER_CLASSES  if danger
        html_attrs[:class] = DEFAULT_PRIMARY_CLASSES if primary
        html_attrs[:class] ||= DEFAULT_SECONDARY_CLASSES
      end
      if method.to_sym == :get
        render_link(label, path, **html_attrs)
      else
        render_form_button(label, path, method: method, **html_attrs)
      end
    end

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
  end
end
