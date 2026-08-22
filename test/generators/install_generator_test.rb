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

  test "install generator creates initializer, flavor, and turbo frame" do
    run_generator ["--flavor", "tailwind"]

    assert_file "config/initializers/ultimate_turbo_modal.rb" do |content|
      assert_includes content, ":tailwind"
    end

    assert_file "config/initializers/ultimate_turbo_modal_tailwind.rb"

    assert_file "app/views/layouts/application.html.erb" do |content|
      assert_includes content, %(turbo_frame_tag "modal")
    end
  end
end
