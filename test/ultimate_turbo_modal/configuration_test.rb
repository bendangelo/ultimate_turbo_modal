# frozen_string_literal: true

require "test_helper"

class UltimateTurboModalConfigurationTest < Minitest::Test
  def setup
    UltimateTurboModal.reset_configuration!
  end

  def test_native_sheet_config_has_defaults
    config = UltimateTurboModal.configuration.native_sheet_config

    assert_respond_to config, :detect
    assert_respond_to config, :action_renderer
    assert_respond_to config, :wrapper_partial
    assert_respond_to config, :wrapper_controller
    assert_respond_to config, :wrapper_selector

    assert_equal false, config.detect.call({})
    assert_equal UltimateTurboModal::NativeActionRenderer, config.action_renderer
    assert_equal "ultimate_turbo_modal/native_sheet_wrapper", config.wrapper_partial
    assert_equal "native-sheet", config.wrapper_controller
    assert_equal "data-native-sheet-content", config.wrapper_selector
  end

  def test_native_sheet_config_detect_is_pluggable
    UltimateTurboModal.configure do |config|
      config.native_sheet do |native_sheet|
        native_sheet.detect = ->(context) { context[:user_agent] == "NativeApp" }
      end
    end

    native_sheet = UltimateTurboModal.configuration.native_sheet_config

    assert_equal true, native_sheet.detect.call({user_agent: "NativeApp"})
    assert_equal false, native_sheet.detect.call({user_agent: "Mozilla"})
  end

  def test_reset_configuration_restores_defaults
    UltimateTurboModal.configure do |config|
      config.native_sheet do |native_sheet|
        native_sheet.detect = ->(context) { context == "native" }
        native_sheet.action_renderer = :some_renderer
      end
    end

    UltimateTurboModal.reset_configuration!

    config = UltimateTurboModal.configuration.native_sheet_config

    assert_equal false, config.detect.call({})
    assert_equal UltimateTurboModal::NativeActionRenderer, config.action_renderer
  end
end
