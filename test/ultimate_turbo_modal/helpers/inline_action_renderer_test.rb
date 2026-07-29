# frozen_string_literal: true

require "test_helper"
require "action_view"

class UltimateTurboModalInlineActionRendererTest < Minitest::Test
  class FakeView
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::UrlHelper
    include ActionView::Helpers::FormTagHelper

    attr_accessor :output_buffer, :native_app_mode, :native_sheet_mode

    def initialize
      @native_app_mode = false
      @native_sheet_mode = false
    end

    def capture(*args, &block)
      block.call(*args)
    end

    def native_sheet?
      @native_sheet_mode
    end

    def hotwire_native_app?
      @native_app_mode
    end

    def native_full_page?
      hotwire_native_app? && !native_sheet?
    end
  end

  class FakeBuilder
    attr_reader :view, :configuration

    def initialize(view)
      @view = view
      @configuration = UltimateTurboModal.configuration
    end

    def native_full_page?
      view.native_full_page?
    end
  end

  def setup
    UltimateTurboModal.reset_configuration!
    @view = FakeView.new
    @builder = FakeBuilder.new(@view)
    @renderer = UltimateTurboModal::InlineActionRenderer.new(@builder)
  end

  def test_submit_renders_normally_in_browser_full_page
    @view.native_app_mode = false
    @builder = FakeBuilder.new(@view)
    @renderer = UltimateTurboModal::InlineActionRenderer.new(@builder)
    @renderer.submit("Save", form: "f")
    html = @renderer.render.to_s
    assert_includes html, "Save"
    assert_includes html, "form=\"f\""
    assert_includes html, "btn btn-primary"
  end

  def test_inline_renderer_returns_empty_in_native_full_page_when_configured
    UltimateTurboModal.configure do |config|
      config.hide_inline_actions_in_native_full_page = true
    end
    @view.native_app_mode = true
    @view.native_sheet_mode = false
    @builder = FakeBuilder.new(@view)
    @renderer = UltimateTurboModal::InlineActionRenderer.new(@builder)
    assert_equal "", @renderer.submit("Save", form: "f")
    assert_equal "", @renderer.cancel("Cancel")
    assert_equal "", @renderer.button("Delete", path: "/delete")
  end

  def test_inline_renderer_renders_normally_in_browser_full_page_even_when_configured
    UltimateTurboModal.configure do |config|
      config.hide_inline_actions_in_native_full_page = true
    end
    @view.native_app_mode = false
    @view.native_sheet_mode = false
    @builder = FakeBuilder.new(@view)
    @renderer = UltimateTurboModal::InlineActionRenderer.new(@builder)
    @renderer.submit("Save", form: "f")
    html = @renderer.render.to_s
    refute_equal "", html
    assert_includes html, "Save"
  end
end
