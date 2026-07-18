# frozen_string_literal: true

require "test_helper"
require "rails/generators"
require_relative "../../lib/generators/ultimate_turbo_modal/install_generator"

class InstallGeneratorTest < Rails::Generators::TestCase
  tests UltimateTurboModal::Generators::InstallGenerator
  destination File.expand_path("../tmp/dummy_app", __dir__)

  setup do
    prepare_destination

    # Create a minimal Rails app skeleton in the destination
    dirs = %w[app/javascript/controllers app/views/layouts config/initializers]
    dirs.each { |dir| FileUtils.mkdir_p(File.join(destination_root, dir)) }

    File.write(File.join(destination_root, "app/javascript/controllers/index.js"), "import { Application } from \"@hotwired/stimulus\"\n\nconst application = Application.start()\n")
    File.write(File.join(destination_root, "app/views/layouts/application.html.erb"), "<html>\n<body>\n</body>\n</html>\n")
    File.write(File.join(destination_root, "config/importmap.rb"), "pin \"application\"\n")
  end

  test "install generator copies native modal frame and sheet controllers" do
    run_generator ["--flavor", "tailwind"]

    assert_file "app/javascript/controllers/native_modal_frame_controller.js" do |content|
      assert_includes content, "intercept(event)"
      assert_includes content, "event.detail.fetchOptions"
      assert_includes content, "window.Turbo?.visit(event.detail.url)"
    end

    assert_file "app/javascript/controllers/native_sheet_controller.js" do |content|
      assert_includes content, "dismiss()"
      assert_includes content, "window.history.back()"
    end
  end
end
