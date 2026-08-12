# frozen_string_literal: true

require "test_helper"
require "action_view"

class UltimateTurboModalNativeSplitActionRendererTest < Minitest::Test
  class FakeView
    include ActionView::Helpers::TagHelper

    attr_accessor :output_buffer
  end

  class FakeBuilder
    attr_reader :view, :configuration

    def initialize(view)
      @view = view
      @configuration = UltimateTurboModal.configuration
    end
  end

  def setup
    UltimateTurboModal.reset_configuration!
    @view = FakeView.new
    @renderer = UltimateTurboModal::NativeSplitActionRenderer.new(FakeBuilder.new(@view))
  end

  def rendered_html
    @renderer.render.to_s
  end

  def test_submit_primary_emits_bridge_primary_action
    @renderer.submit("Save", form: "edit-form", primary: true)
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--primary-action\""
    assert_includes html, "Save"
    assert_includes html, "edit-form"
  end

  def test_submit_overflow_accumulates_into_overflow_menu
    @renderer.submit("Delete", form: "delete-form", overflow: true)
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--overflow-menu\""
    assert_includes html, "Delete"
    assert_includes html, "delete-form"
    refute_includes html, "data-controller=\"bridge--primary-action\""
  end

  def test_button_with_path_and_method_emits_primary_action
    @renderer.button("Navigate", path: "/somewhere", method: :get, primary: true)
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--primary-action\""
    assert_includes html, "Navigate"
    assert_includes html, "/somewhere"
    assert_includes html, "get"
  end

  def test_cancel_is_noop
    @renderer.cancel("Close")
    html = rendered_html

    assert_equal "", html
  end

  def test_multiple_actions_produce_one_primary_and_one_overflow
    @renderer.submit("Save", form: "form-1", primary: true)
    @renderer.submit("Delete", form: "form-2", overflow: true)
    @renderer.button("Back", path: "/back", method: :get, overflow: true)
    html = rendered_html

    assert_equal 1, html.scan("data-controller=\"bridge--primary-action\"").length
    assert_equal 1, html.scan("data-controller=\"bridge--overflow-menu\"").length
  end

  def test_overflow_menu_adds_explicit_items
    @renderer.overflow_menu([
      { label: "Option A", path: "/a", method: :get },
      { label: "Option B", path: "/b", method: :post }
    ])
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--overflow-menu\""
    assert_includes html, "Option A"
    assert_includes html, "Option B"
  end

  def test_render_footer_aliases_render
    @renderer.submit("Save", form: "f", primary: true)
    html1 = @renderer.render.to_s
    @renderer2 = UltimateTurboModal::NativeSplitActionRenderer.new(FakeBuilder.new(@view))
    @renderer2.submit("Save", form: "f", primary: true)
    html2 = @renderer2.render_footer.to_s

    assert_equal html1, html2
  end

  def test_default_icons
    @renderer.submit("Save", form: "f", primary: true)
    @renderer.submit("Delete", form: "d", overflow: true)
    html = rendered_html

    assert_includes html, "check"
    assert_includes html, "dots-three-vertical"
  end

  def test_custom_overflow_icon
    @renderer.overflow_menu([{ label: "Option", path: "/o" }], icon: "custom-icon")
    html = rendered_html

    assert_includes html, "custom-icon"
    refute_includes html, "dots-three-vertical"
  end

  def test_submit_name_and_value_forwarded_in_payload
    @renderer.submit("Save", form: "f", primary: true, name: "commit", value: "Save")
    html = rendered_html

    assert_includes html, "commit"
    assert_includes html, "Save"
  end

  def test_destructive_flag_forwarded
    @renderer.button("Delete", path: "/delete", method: :delete, primary: true, destructive: true)
    html = rendered_html

    assert_includes html, "true"
  end

  def test_submit_without_primary_or_overflow_defaults_to_primary
    @renderer.submit("Save", form: "my-form")
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--primary-action\""
    assert_includes html, "my-form"
    assert_includes html, "Save"
  end

  def test_submit_with_overflow_true_goes_to_overflow
    @renderer.submit("Delete", form: "delete-form", overflow: true)
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--overflow-menu\""
    refute_includes html, "data-controller=\"bridge--primary-action\""
  end

  def test_button_without_primary_or_overflow_is_noop
    @renderer.button("Hidden", path: "/x", method: :get)
    html = rendered_html

    assert_equal "", html
  end

  def test_submit_primary_omits_label_when_native
    @view.define_singleton_method(:hotwire_native_app?) { true }
    @renderer.submit("Save", form: "f", primary: true)
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--primary-action\""
    payload = extract_payload(html, "bridge--primary-action")
    refute payload.key?("label"), "label should be omitted on native"
    assert_equal "check", payload["icon"]
  end

  def test_submit_primary_includes_label_when_not_native
    @view.define_singleton_method(:hotwire_native_app?) { false }
    @renderer.submit("Save", form: "f", primary: true)
    html = rendered_html

    payload = extract_payload(html, "bridge--primary-action")
    assert_equal "Save", payload["label"]
  end

  def test_submit_with_custom_icon_on_native
    @view.define_singleton_method(:hotwire_native_app?) { true }
    @renderer.submit("Send", form: "f", primary: true, icon: "paper-plane")
    html = rendered_html

    payload = extract_payload(html, "bridge--primary-action")
    refute payload.key?("label")
    assert_equal "paper-plane", payload["icon"]
  end

  def test_button_primary_omits_label_when_native
    @view.define_singleton_method(:hotwire_native_app?) { true }
    @renderer.button("Navigate", path: "/x", method: :get, primary: true)
    html = rendered_html

    payload = extract_payload(html, "bridge--primary-action")
    refute payload.key?("label"), "label should be omitted on native"
  end

  private

  def extract_payload(html, controller_name)
    json = html.match(/data-#{controller_name}-payload-value="([^"]+)"/)&.[](1)
    JSON.parse(CGI.unescapeHTML(json || "{}"))
  end
end
