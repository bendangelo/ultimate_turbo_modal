# frozen_string_literal: true

require "test_helper"
require "action_view"

class UltimateTurboModalNativeHeaderActionRendererTest < Minitest::Test
  class FakeView
    include ActionView::Helpers::TagHelper

    attr_accessor :output_buffer, :title_content

    def content_for(name)
      return @title_content if name == :title
      nil
    end
  end

  def setup
    @view = FakeView.new
    @view.title_content = "Edit Customer"
    @renderer = UltimateTurboModal::NativeHeaderActionRenderer.new(@view)
  end

  def rendered_html
    @renderer.render.to_s
  end

  def test_submit_renders_bridge_header_with_submit_form
    @renderer.submit("Save Changes", form: "edit-customer-form", icon: "check")
    html = rendered_html

    assert_includes html, "data-controller=\"bridge--header\""
    payload = extract_payload(html)
    assert_equal "Edit Customer", payload["title"]
    assert_equal "Save Changes", payload["primary_action"]["label"]
    assert_equal "check", payload["primary_action"]["icon"]
    assert_equal "edit-customer-form", payload["primary_action"]["submit_form"]
    refute payload["primary_action"].key?("path")
  end

  def test_button_renders_bridge_header_with_path_and_method
    @renderer.button("Delete", path: "/items/1", method: :delete, icon: "trash")
    html = rendered_html

    payload = extract_payload(html)
    assert_equal "Delete", payload["primary_action"]["label"]
    assert_equal "/items/1", payload["primary_action"]["path"]
    assert_equal "delete", payload["primary_action"]["method"]
    assert_equal "trash", payload["primary_action"]["icon"]
  end

  def test_html_attributes_are_forwarded
    @renderer.submit("Save", form: "form-1", class: "my-class", data: { icon: "plus" })
    html = rendered_html

    assert_includes html, "class=\"my-class\""
    assert_includes html, "data-icon=\"plus\""
  end

  def test_cancel_is_noop
    @renderer.cancel("Cancel")
    assert_equal "", rendered_html
  end

  def test_default_icon_is_check_when_none_provided
    @renderer.submit("Save", form: "form-1")
    html = rendered_html
    payload = extract_payload(html)
    assert_equal "check", payload["primary_action"]["icon"]
  end

  def test_position_defaults_to_right
    @renderer.submit("Save", form: "form-1")
    html = rendered_html
    payload = extract_payload(html)
    assert_equal "right", payload["primary_action"]["position"]
  end

  def test_renders_multiple_actions_as_multiple_header_divs
    @renderer.submit("Save", form: "form-1")
    @renderer.button("Back", path: "/back", method: :get, icon: "arrow-left")
    html = rendered_html

    assert_equal 2, html.scan("data-controller=\"bridge--header\"").length
  end

  private

  def extract_payload(html)
    match = html.match(/data-bridge--header-payload-value='([^']+)'/)
    match ||= html.match(/data-bridge--header-payload-value=\"([^\"]+)\"/)
    flunk("No bridge--header payload found") unless match
    JSON.parse(match[1].gsub("&quot;", '"'))
  end
end
