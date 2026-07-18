# frozen_string_literal: true

require "minitest/autorun"
require "active_support/core_ext/module/delegation"
require "action_dispatch"
require "rails"
require "action_controller/railtie"
require "action_view/railtie"
require "turbo-rails"
require "phlex-rails"

module UltimateTurboModal
  class TestApplication < Rails::Application
    config.load_defaults 8.0
  end
end

Rails.application = UltimateTurboModal::TestApplication.new

$LOAD_PATH << Gem.loaded_specs["turbo-rails"].full_gem_path + "/app/helpers"
require "turbo/frames_helper"
require "turbo/streams_helper"
require "ultimate_turbo_modal"
