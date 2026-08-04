# frozen_string_literal: true

module UltimateTurboModal
  class InlineActionRenderer
    DEFAULT_PRIMARY_CLASSES   = "btn btn-primary"
    DEFAULT_SECONDARY_CLASSES = "btn btn-secondary"
    DEFAULT_DANGER_CLASSES    = "btn btn-danger"

    attr_reader :builder

    def initialize(builder)
      @builder = builder
      @view = builder.view
      @output = ActionView::OutputBuffer.new
    end

    def render
      @output.to_s
    end

    def cancel(label, path = nil, **html_attrs)
      html_attrs[:class] = css_class_for(:secondary) if html_attrs[:class].blank?
      if path
        render_link(label, path, **html_attrs)
      else
        render_button(label, type: "button", **html_attrs)
      end
    end

    def submit(label, form:, primary: false, secondary: false, danger: false, **html_attrs)
      if html_attrs[:class].blank?
        html_attrs[:class] =
          if danger
            css_class_for(:danger)
          elsif secondary
            css_class_for(:secondary)
          else
            css_class_for(:primary)
          end
      end
      render_button(label, type: "submit", form: form, **html_attrs)
    end

    def button(label, path:, method: :get, primary: false, danger: false, **html_attrs)
      if html_attrs[:class].blank?
        html_attrs[:class] = css_class_for(:danger)  if danger
        html_attrs[:class] = css_class_for(:primary) if primary
        html_attrs[:class] ||= css_class_for(:secondary)
      end
      if method.to_sym == :get
        render_link(label, path, **html_attrs)
      else
        render_form_button(label, path, method: method, **html_attrs)
      end
    end

    private

    def css_class_for(role)
      cfg = @builder.configuration
      case role
      when :primary   then cfg.primary_action_classes   || DEFAULT_PRIMARY_CLASSES
      when :secondary then cfg.secondary_action_classes || DEFAULT_SECONDARY_CLASSES
      when :danger    then cfg.danger_action_classes    || DEFAULT_DANGER_CLASSES
      else DEFAULT_PRIMARY_CLASSES
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
      form_attrs = {method: method.to_s, url: path, class: "inline"}
      button_attrs = attrs.except(:form)
      @output.safe_concat(@view.form_with(**form_attrs) do
        @view.tag.button(label, **button_attrs)
      end)
    end
  end
end
