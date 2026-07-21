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
    refute_includes result, "bg-blue-600"
    refute_includes result, "bg-slate-100"
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
    refute_includes result, "bg-white"
    refute_includes result, "border-slate-200"
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
end
