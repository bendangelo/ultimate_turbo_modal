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

    attr_accessor :ultimate_turbo_modal_context

    def output_buffer
      @output_buffer ||= ActionView::OutputBuffer.new
    end

    attr_writer :output_buffer

    def capture(*args, &block)
      block.call(*args)
    end

    def native_sheet?
      ultimate_turbo_modal_context == :native_sheet
    end

    def inside_modal?
      ultimate_turbo_modal_context == :modal
    end

    def request
      @request ||= Struct.new(:headers).new({})
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
    refute_includes result, "sticky"
  end

  def test_renders_modal_footer_inside_modal
    @view.ultimate_turbo_modal_context = :modal
    result = @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "Cancel"
    assert_includes result, "Save"
    assert_includes result, "sticky"
  end

  def test_renders_native_bridge_buttons_in_native_sheet
    @view.ultimate_turbo_modal_context = :native_sheet
    result = @view.actions do |actions|
      actions.button("Edit", path: "/edit", method: :get)
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "data-controller=\"bridge--button\""
    assert_includes result, "data-bridge-button-title-value=\"Edit\""
    assert_includes result, "data-bridge-button-path-value=\"/edit\""
    assert_includes result, "data-bridge-button-method-value=\"get\""
    assert_includes result, "data-bridge-button-submit-form-value=\"my-form\""
    refute_includes result, "Cancel"
  end

  def test_native_cancel_emits_dismiss_bridge
    @view.ultimate_turbo_modal_context = :native_sheet
    result = @view.actions do |actions|
      actions.cancel("Close")
    end

    assert_includes result, "data-bridge-button-bridge-value=\"dismiss\""
    refute_includes result, "data-bridge-button-path-value"
  end

  def test_modal_cancel_uses_path_and_button_tag
    @view.ultimate_turbo_modal_context = :modal
    result = @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
    end

    assert_includes result, "<a"
    assert_includes result, "/cancel"
  end

  def test_modal_submit_is_button_tag_with_form_attribute
    @view.ultimate_turbo_modal_context = :modal
    result = @view.actions do |actions|
      actions.submit("Save", form: "my-form")
    end

    assert_includes result, "<button"
    assert_includes result, "form=\"my-form\""
  end

  def test_action_builder_tracks_modal_context_around_modal_call
    view = FakeView.new
    called = false
    view.define_singleton_method(:modal) do |**|
      called = true
      "rendered"
    end

    assert_equal false, view.inside_modal?

    view.modal(request: view.request)
    assert_equal true, called
  end
end
