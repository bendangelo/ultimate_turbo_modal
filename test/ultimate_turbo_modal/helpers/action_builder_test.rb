# frozen_string_literal: true

require "test_helper"
require "action_view"

class UltimateTurboModalActionBuilderTest < Minitest::Test
  class FakeView
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormHelper
    include ActionView::Helpers::UrlHelper
    include UltimateTurboModal::Helpers::ViewHelper

    attr_accessor :turbo_frame_header

    def output_buffer
      @output_buffer ||= ActionView::OutputBuffer.new
    end

    attr_writer :output_buffer

    def capture(*args, &block)
      block.call(*args)
    end

    def native_sheet?
      false
    end

    def request
      @request ||= Struct.new(:headers).new({"Turbo-Frame" => turbo_frame_header})
    end
  end

  def setup
    UltimateTurboModal.reset_configuration!
    @view = FakeView.new
  end

  def test_renders_inline_actions_by_default
    result = @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
      actions.button("Details", path: "/details", method: :get)
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "Cancel"
    assert_includes result, "/cancel"
    assert_includes result, "Details"
    assert_includes result, "/details"
    assert_includes result, "Save"
    assert_includes result, "my-form"
    refute_includes result, "data-controller=\"bridge--button\""
    refute_includes result, "data-bridge--button"

    assert_includes result, "btn btn-secondary"
    assert_includes result, "btn btn-primary"
    assert_equal 2, result.scan("btn btn-secondary\"").length
  end

  def test_renders_modal_footer_inside_modal
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "Cancel"
    assert_includes result, "Save"
    assert_includes result, "justify-end"
    assert_includes result, "gap-3"
    assert_includes result, "btn btn-secondary"
    assert_includes result, "btn btn-primary"
  end

  def test_renders_modal_footer_inside_drawer_modal
    @view.turbo_frame_header = "drawer-modal"
    result = @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "Cancel"
    assert_includes result, "Save"
    assert_includes result, "justify-end"
    assert_includes result, "btn btn-secondary"
    assert_includes result, "btn btn-primary"
  end

  def test_renders_native_bridge_buttons_in_native_sheet
    @view.define_singleton_method(:native_sheet?) { true }
    result = @view.actions do |actions|
      actions.button("Edit", path: "/edit", method: :get)
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "data-controller=\"bridge--button\""
    assert_includes result, "data-bridge--button-title-value=\"Edit\""
    assert_includes result, "data-bridge--button-path-value=\"/edit\""
    assert_includes result, "data-bridge--button-method-value=\"get\""
    assert_includes result, "data-bridge--button-submit-form-value=\"my-form\""
    refute_includes result, "Cancel"
  end

  def test_native_cancel_is_noop
    @view.define_singleton_method(:native_sheet?) { true }
    result = @view.actions do |actions|
      actions.cancel("Close", "/somewhere")
    end

    assert_equal "", result
  end

  def test_modal_cancel_uses_path_and_button_tag
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
    end

    assert_includes result, "<a"
    assert_includes result, "/cancel"
  end

  def test_modal_submit_is_button_tag_with_form_attribute
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "<button"
    assert_includes result, "form=\"my-form\""
  end

  def test_actions_inside_modal_block_resolves_to_modal_footer_renderer
    called = false
    @view.turbo_frame_header = "modal"
    @view.define_singleton_method(:modal) do |**, &block|
      actions(&block)
    end

    result = @view.modal do |actions|
      called = true
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    assert called
    assert_includes result, "Cancel"
    assert_includes result, "Save"
    assert_includes result, "justify-end"
  end

  def test_render_footer_returns_unwrapped_buttons_for_component_slot
    @view.turbo_frame_header = "modal"
    builder = UltimateTurboModal::ActionBuilder.new(@view)
    builder.cancel("Cancel", "/cancel")
    builder.submit("Save", form: "my-form")

    footer_html = builder.render_footer

    assert_includes footer_html, "Cancel"
    assert_includes footer_html, "/cancel"
    assert_includes footer_html, "Save"
    assert_includes footer_html, "form=\"my-form\""
    refute_includes footer_html, "justify-end"
    refute_includes footer_html, "gap-3"
  end

  def test_submit_with_danger_true_uses_danger_default
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.submit("Delete", form: "my-form", danger: true)
    end

    assert_includes result, "btn btn-danger"
    refute_includes result, "btn btn-primary"
    refute_includes result, "btn btn-secondary"
  end

  def test_button_with_primary_true_uses_primary_default
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.button("Print", path: "/print", method: :get, primary: true)
    end

    assert_includes result, "btn btn-primary"
    refute_includes result, "btn btn-secondary"
  end

  def test_explicit_class_overrides_defaults
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.submit("Save", form: "my-form", class: "custom-class")
    end

    assert_includes result, "custom-class"
    refute_includes result, "btn"
  end

  def test_danger_takes_precedence_over_primary
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.submit("Delete", form: "my-form", primary: true, danger: true)
    end

    assert_includes result, "btn btn-danger"
    refute_includes result, "btn btn-primary"
  end

  def test_inline_actions_get_default_classes
    result = @view.actions do |actions|
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "btn btn-primary"
  end

  def test_button_with_explicit_class_does_not_apply_default
    @view.turbo_frame_header = "modal"
    result = @view.actions do |actions|
      actions.button("Details", path: "/details", method: :get, class: "my-custom-class")
    end

    assert_includes result, "my-custom-class"
    refute_includes result, "btn"
  end
end
