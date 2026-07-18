# frozen_string_literal: true

require "test_helper"

class UltimateTurboModalBaseTest < Minitest::Test
  class TestModal < UltimateTurboModal::Base
    STYLES = ""
    MODAL_DIALOG_CLASSES = ""
    MODAL_INNER_CLASSES = ""
    MODAL_CONTENT_CLASSES = ""
    MODAL_MAIN_CLASSES = ""
    MODAL_HEADER_CLASSES = ""
    MODAL_TITLE_CLASSES = ""
    MODAL_TITLE_H_CLASSES = ""
    MODAL_CLOSE_CLASSES = ""
    MODAL_CLOSE_BUTTON_CLASSES = ""
    MODAL_CLOSE_ICON_CLASSES = ""
    MODAL_CLOSE_SR_CLASSES = ""
    DRAWER_DIALOG_CLASSES = ""
    DRAWER_WRAPPER_CLASSES = ""
    DRAWER_PANEL_CLASSES = ""
    DRAWER_CONTENT_CLASSES = ""
    DRAWER_MAIN_CLASSES = ""
    DRAWER_HEADER_CLASSES = ""
    DRAWER_TITLE_CLASSES = ""
    DRAWER_TITLE_H_CLASSES = ""
    DRAWER_CLOSE_CLASSES = ""
    DRAWER_CLOSE_BUTTON_CLASSES = ""
    DRAWER_CLOSE_ICON_CLASSES = ""
    DRAWER_CLOSE_SR_CLASSES = ""
  end

  def setup
    UltimateTurboModal.reset_configuration!
  end

  def test_close_on_submit_success_uses_global_config_by_default
    UltimateTurboModal.configuration.close_on_submit_success = true
    modal = TestModal.new(request: nil)

    assert_equal true, modal.close_on_submit_success?
  end

  def test_close_on_submit_success_can_be_disabled_per_modal
    UltimateTurboModal.configuration.close_on_submit_success = true
    modal = TestModal.new(request: nil, close_on_submit_success: false)

    assert_equal false, modal.close_on_submit_success?
  end

  def test_close_on_submit_success_can_be_enabled_per_modal_when_global_is_false
    UltimateTurboModal.configuration.close_on_submit_success = false
    modal = TestModal.new(request: nil, close_on_submit_success: true)

    assert_equal true, modal.close_on_submit_success?
  end
end
