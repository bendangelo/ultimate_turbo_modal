# frozen_string_literal: true

module UltimateTurboModal
  class NativeSplitActionRenderer
    DEFAULT_PRIMARY_ICON = "check"
    DEFAULT_OVERFLOW_ICON = "dots-three-vertical"

    def initialize(builder)
      @builder = builder
      @view = builder.view
      @output = ActionView::OutputBuffer.new
      @overflow_items = []
    end

    def render
      emit_overflow_menu
      @output.to_s.html_safe
    end
    alias_method :render_footer, :render

    def cancel(_label, _path = nil, **_html_attrs)
      nil
    end

    def submit(label, form: nil, primary: false, overflow: false, **html_attrs)
      item = Helpers::NativeOverflowItem.normalize(
        html_attrs.merge(
          label: label,
          submit_form: form,
          submit_name: html_attrs[:name],
          submit_value: html_attrs[:value]
        )
      )
      primary ? emit_primary_action(item) : add_to_overflow(item, overflow)
    end

    def button(label, path:, method: :get, primary: false, overflow: false, **html_attrs)
      item = Helpers::NativeOverflowItem.normalize(
        html_attrs.merge(
          label: label,
          path: path,
          method: method.to_s
        )
      )
      primary ? emit_primary_action(item) : add_to_overflow(item, overflow)
    end

    def overflow_menu(items, icon: nil)
      items.each { |i| add_to_overflow(Helpers::NativeOverflowItem.normalize(i)) }
      @overflow_icon = icon
    end

    private

    def add_to_overflow(item, overflow = true)
      @overflow_items << item if overflow
    end

    def emit_primary_action(item)
      icon = item.delete(:icon) || DEFAULT_PRIMARY_ICON
      label = item.delete(:label)

      payload = {
        key: item.delete(:key) || "primary",
        label: native_icon_only? ? nil : label,
        icon: icon,
        path: item.delete(:path),
        method: item.delete(:method) || "get",
        bridge: item.delete(:bridge),
        submit_form: item.delete(:submit_form),
        submit_name: item.delete(:submit_name),
        submit_value: item.delete(:submit_value),
        target: item.delete(:target),
        confirm: item.delete(:confirm),
        destructive: item.delete(:destructive) || false
      }.merge(item).compact

      div_attrs = {}
      div_attrs[:data] = {
        controller: "bridge--primary-action",
        "bridge--primary-action-payload-value": payload.to_json
      }

      @output.safe_concat(@view.tag.div("", **div_attrs, aria: { hidden: "true" }))
    end

    def native_icon_only?
      @view.respond_to?(:hotwire_native_app?) && @view.hotwire_native_app?
    end

    def emit_overflow_menu
      return if @overflow_items.empty?

      payload = {
        icon: @overflow_icon || DEFAULT_OVERFLOW_ICON,
        items: @overflow_items
      }.compact

      @output.safe_concat(
        @view.tag.div("",
          data: {
            controller: "bridge--overflow-menu",
            "bridge--overflow-menu-payload-value": payload.to_json
          },
          aria: { hidden: "true" }
        )
      )
    end
  end
end
