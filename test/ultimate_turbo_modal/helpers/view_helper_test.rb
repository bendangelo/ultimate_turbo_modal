# frozen_string_literal: true

require "test_helper"

class UltimateTurboModalViewHelperTest < Minitest::Test
  class FakeModalComponent
    attr_reader :options

    def initialize(**options)
      @options = options
    end
  end

  class FakeView
    include ActionView::Helpers::TagHelper
    include UltimateTurboModal::Helpers::ViewHelper

    attr_accessor :rendered, :native_sheet_value

    def initialize
      @rendered = []
      @native_sheet_value = false
      @output_buffer = ActionView::OutputBuffer.new
    end

    attr_writer :output_buffer

    def output_buffer
      @output_buffer ||= ActionView::OutputBuffer.new
    end

    def render(target = nil, **options, &block)
      @rendered << [target, options, block]
      "rendered:#{target.respond_to?(:options) ? "component" : target}"
    end

    def capture(*args, &block)
      block.call(*args)
    end

    def request
      @request ||= Struct.new(:headers).new({})
    end

    def native_sheet?
      @native_sheet_value
    end
  end

  def setup
    UltimateTurboModal.reset_configuration!
    @view = FakeView.new
    @original_new = UltimateTurboModal.method(:new)
    UltimateTurboModal.define_singleton_method(:new) do |**options|
      FakeModalComponent.new(**options)
    end
  end

  def teardown
    UltimateTurboModal.define_singleton_method(:new, &@original_new)
  end

  def test_modal_renders_native_wrapper_when_native_sheet_is_true
    @view.native_sheet_value = true
    result = @view.modal(title: "Hello") { "content" }

    assert_equal 1, @view.rendered.size
    target, options, block = @view.rendered.first
    assert_equal UltimateTurboModal.configuration.native_sheet_config.wrapper_partial, target
    assert_equal "Hello", options[:title]
    assert_equal "content", block.call
    assert_equal "rendered:#{target}", result
  end

  def test_modal_renders_component_when_native_sheet_is_false
    result = @view.modal(title: "Hello") { "content" }

    assert_equal 1, @view.rendered.size
    target, _options, block = @view.rendered.first
    assert_kind_of FakeModalComponent, target
    assert_equal "Hello", target.options[:title]
    assert_equal "content", block.call
    assert_equal "rendered:component", result
  end

  def test_drawer_renders_native_wrapper_when_native_sheet_is_true
    @view.native_sheet_value = true
    result = @view.drawer(title: "Drawer") { "content" }

    assert_equal 1, @view.rendered.size
    target, options, block = @view.rendered.first
    assert_equal UltimateTurboModal.configuration.native_sheet_config.wrapper_partial, target
    assert_equal "Drawer", options[:title]
    assert_equal "content", block.call
    assert_equal "rendered:#{target}", result
  end

  def test_drawer_delegates_to_modal_when_native_sheet_is_false
    result = @view.drawer(position: :left, size: :lg, title: "Drawer") { "content" }

    assert_equal 1, @view.rendered.size
    target, _options, block = @view.rendered.first
    assert_kind_of FakeModalComponent, target
    assert_equal :left, target.options[:drawer_position]
    assert_equal :lg, target.options[:size]
    assert_equal "Drawer", target.options[:title]
    assert_equal "content", block.call
    assert_equal "rendered:component", result
  end

  def test_inside_native_sheet_aliases_native_sheet
    @view.native_sheet_value = false
    refute @view.inside_native_sheet?

    @view.native_sheet_value = true
    assert @view.inside_native_sheet?
  end

  def test_modal_forwards_content_div_data_to_wrapper_in_native_sheet
    @view.native_sheet_value = true
    @view.modal(title: "Test", content_div_data: { controller: "custom-ctrl" }) { "content" }

    assert_equal 1, @view.rendered.size
    _target, options, _block = @view.rendered.first
    assert_equal "Test", options[:title]
    assert_equal "custom-ctrl", options.dig(:content_div_data, :controller)
  end

  def test_dismiss_button_uses_modal_hide_in_browser
    html = @view.dismiss_button("Close", class: "btn")
    assert_includes html, 'type="button"'
    assert_includes html, 'class="btn"'
    assert_includes html, "Close"
    assert_includes html, "click-&gt;modal#hide"
    refute_includes html, "native-sheet"
  end

  def test_dismiss_button_uses_native_sheet_dismiss_in_sheet
    @view.native_sheet_value = true
    html = @view.dismiss_button("Close", class: "btn")
    assert_includes html, 'type="button"'
    assert_includes html, "Close"
    assert_includes html, "click-&gt;native-sheet#dismiss"
    refute_includes html, "click-&gt;modal#hide"
  end

  def test_dismiss_button_with_block
    html = @view.dismiss_button(class: "btn") { "X" }
    assert_includes html, 'class="btn"'
    assert_includes html, ">X</button>"
  end
end
