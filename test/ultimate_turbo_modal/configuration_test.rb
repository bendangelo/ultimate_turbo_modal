# frozen_string_literal: true

require "test_helper"

class UltimateTurboModalConfigurationTest < Minitest::Test
  def setup
    UltimateTurboModal.reset_configuration!
  end

  def test_reset_configuration_restores_defaults
    UltimateTurboModal.configure do |config|
      config.close_on_submit_success = false
    end

    UltimateTurboModal.reset_configuration!

    assert_equal true, UltimateTurboModal.configuration.close_on_submit_success
  end

  def test_close_on_submit_success_defaults_to_true
    assert_equal true, UltimateTurboModal.configuration.close_on_submit_success
  end

  def test_close_on_submit_success_can_be_overridden
    UltimateTurboModal.configure do |config|
      config.close_on_submit_success = false
    end

    assert_equal false, UltimateTurboModal.configuration.close_on_submit_success
  end
end