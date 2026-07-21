# frozen_string_literal: true

require "test_helper"
require "action_view"

class UltimateTurboModalNativeActionRendererTest < Minitest::Test
  class FakeView
    include ActionView::Helpers::TagHelper

    attr_accessor :output_buffer
  end

  def setup
    @view = FakeView.new
    @renderer = UltimateTurboModal::NativeActionRenderer.new(@view)
  end

  def rendered_html
    @renderer.render.to_s
  end

  def test_submit_renders_bridge_button_with_form
    @renderer.submit("Save", form: "edit-form")
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--button\""
    assert_includes html, "data-bridge--button-title-value=\"Save\""
    assert_includes html, "data-bridge--button-submit-form-value=\"edit-form\""
    refute_includes html, "data-bridge--button-path-value"
  end

  def test_button_renders_bridge_button_with_path_and_method
    @renderer.button("Delete", path: "/items/1", method: :delete)
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--button\""
    assert_includes html, "data-bridge--button-title-value=\"Delete\""
    assert_includes html, "data-bridge--button-path-value=\"/items/1\""
    assert_includes html, "data-bridge--button-method-value=\"delete\""
  end

  def test_cancel_is_noop
    @renderer.cancel("Close")
    html = rendered_html

    assert_equal "", html
  end

  def test_renders_multiple_actions
    @renderer.submit("Save", form: "form-1")
    @renderer.button("Back", path: "/back", method: :get)
    html = rendered_html

    assert_equal 2, html.scan("data-controller=\"bridge--button\"").length
  end

  def test_passes_html_attributes_through
    @renderer.button("Click", path: "/click", method: :get, data: {icon: "plus"}, class: "custom")
    html = rendered_html

    assert_includes html, "data-icon=\"plus\""
    assert_includes html, "class=\"custom\""
  end
end
