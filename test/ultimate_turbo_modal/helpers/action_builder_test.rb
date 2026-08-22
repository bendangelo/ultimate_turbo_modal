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

    def request
      @request ||= Struct.new(:headers).new({"Turbo-Frame" => turbo_frame_header})
    end

    # Stub a modal component so `actions` can pass the builder to it
    def stub_modal_component!
      @ultimate_turbo_modal_component = StubModalComponent.new
    end

    def reset_modal_component!
      @ultimate_turbo_modal_component = nil
    end

    def render_captured_footer
      @ultimate_turbo_modal_component&.render_captured_footer || ""
    end
  end

  class StubModalComponent
    attr_reader :captured_builder

    def actions(builder)
      @captured_builder = builder
    end

    def render_captured_footer
      @captured_builder&.render_footer || ""
    end
  end

  def setup
    UltimateTurboModal.reset_configuration!
    @view = FakeView.new
    @view.stub_modal_component!
  end

  def test_renders_modal_footer_inside_modal
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    result = @view.render_captured_footer
    assert_includes result, "Cancel"
    assert_includes result, "Save"
    refute_includes result, "justify-end"
    refute_includes result, "gap-3"
    assert_includes result, "btn btn-secondary"
    assert_includes result, "btn btn-primary"
  end

  def test_renders_modal_footer_inside_drawer_modal
    @view.turbo_frame_header = "drawer-modal"
    @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    result = @view.render_captured_footer
    assert_includes result, "Cancel"
    assert_includes result, "Save"
    assert_includes result, "btn btn-secondary"
    assert_includes result, "btn btn-primary"
  end

  def test_modal_cancel_uses_path_and_button_tag
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.cancel("Cancel", "/cancel")
    end

    result = @view.render_captured_footer
    assert_includes result, "<a"
    assert_includes result, "/cancel"
  end

  def test_modal_submit_is_button_tag_with_form_attribute
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.submit("Save", form: "my-form")
    end

    result = @view.render_captured_footer
    assert_includes result, "<button"
    assert_includes result, "form=\"my-form\""
  end

  def test_actions_inside_modal_block_resolves_to_modal_footer_renderer
    called = false
    @view.turbo_frame_header = "modal"
    @view.define_singleton_method(:modal) do |**, &block|
      actions(&block)
    end

    @view.modal do |actions|
      called = true
      actions.cancel("Cancel", "/cancel")
      actions.submit("Save", form: "my-form")
    end

    result = @view.render_captured_footer
    assert called
    assert_includes result, "Cancel"
    assert_includes result, "Save"
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
    @view.actions do |actions|
      actions.submit("Delete", form: "my-form", danger: true)
    end

    result = @view.render_captured_footer
    assert_includes result, "btn btn-danger"
    refute_includes result, "btn btn-primary"
    refute_includes result, "btn btn-secondary"
  end

  def test_button_with_primary_true_uses_primary_default
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.button("Print", path: "/print", method: :get, primary: true)
    end

    result = @view.render_captured_footer
    assert_includes result, "btn btn-primary"
    refute_includes result, "btn btn-secondary"
  end

  def test_explicit_class_overrides_defaults
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.submit("Save", form: "my-form", class: "custom-class")
    end

    result = @view.render_captured_footer
    assert_includes result, "custom-class"
    refute_includes result, "btn"
  end

  def test_danger_takes_precedence_over_primary
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.submit("Delete", form: "my-form", primary: true, danger: true)
    end

    result = @view.render_captured_footer
    assert_includes result, "btn btn-danger"
    refute_includes result, "btn btn-primary"
  end

  def test_button_with_explicit_class_does_not_apply_default
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.button("Details", path: "/details", method: :get, class: "my-custom-class")
    end

    result = @view.render_captured_footer
    assert_includes result, "my-custom-class"
    refute_includes result, "btn"
  end

  def test_button_with_delete_method_renders_form_pointing_at_path
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.button("Delete", path: "/things/1", method: :delete)
    end

    result = @view.render_captured_footer
    assert_includes result, %(action="/things/1"), "form action must match the given path, not the current request URL"
    assert_includes result, %(name="_method" value="delete"), "form must carry the _method override for DELETE"
    assert_includes result, "Delete"
  end

  def test_button_with_post_method_renders_form_pointing_at_path
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.button("Approve", path: "/things/1/approve", method: :post)
    end

    result = @view.render_captured_footer
    assert_includes result, %(action="/things/1/approve"), "form action must match the given path, not the current request URL"
    assert_includes result, "Approve"
  end

  def test_selects_modal_renderer_inside_modal
    @view.turbo_frame_header = "modal"
    builder = UltimateTurboModal::ActionBuilder.new(@view)
    assert_instance_of UltimateTurboModal::ModalActionRenderer, builder.renderer
  end

  def test_selects_inline_renderer_for_browser_full_page
    @view.turbo_frame_header = nil
    builder = UltimateTurboModal::ActionBuilder.new(@view)
    assert_instance_of UltimateTurboModal::InlineActionRenderer, builder.renderer
  end

  def test_overflow_menu_is_ignored_by_modal_renderer
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.overflow_menu([{label: "Delete", path: "/delete"}])
    end

    result = @view.render_captured_footer
    assert_equal "", result
  end

  def test_submit_form_is_optional
    @view.turbo_frame_header = "modal"
    @view.actions do |actions|
      actions.submit("Save")
    end

    result = @view.render_captured_footer
    assert_includes result, "Save"
    assert_includes result, "btn btn-primary"
  end

  def test_actions_outside_modal_or_sheet_renders_inline
    @view.reset_modal_component!
    result = @view.actions do |actions|
      actions.button("New", path: "/new")
    end

    assert_includes result, "New"
    assert_includes result, "/new"
    assert_includes result, "btn btn-secondary"
  end
end
