# frozen_string_literal: true

module UltimateTurboModal::Helpers
  module ViewHelper
    def modal(**, &)
      with_ultimate_turbo_modal_context(:modal) do
        render(UltimateTurboModal.new(request:, **), &)
      end
    end

    def drawer(position: nil, size: nil, **options, &block)
      cfg = UltimateTurboModal.configuration.drawer_config
      position = UltimateTurboModal::Base.validate_drawer_position!(position || cfg.position)
      size = UltimateTurboModal::Base.validate_drawer_size!(size || cfg.size)
      modal(drawer_position: position, size: size, **options, &block)
    end

    def actions(&block)
      builder = UltimateTurboModal::ActionBuilder.new(self)
      block.call(builder)
      builder.render
    end

    def native_sheet?
      UltimateTurboModal.configuration.native_sheet_config.detect.call(self)
    end

    def inside_modal?
      !!ultimate_turbo_modal_context
    end

    private

    def ultimate_turbo_modal_context
      Thread.current[:ultimate_turbo_modal_context]
    end

    def ultimate_turbo_modal_context=(value)
      Thread.current[:ultimate_turbo_modal_context] = value
    end

    def with_ultimate_turbo_modal_context(value)
      previous = ultimate_turbo_modal_context
      self.ultimate_turbo_modal_context = value
      yield
    ensure
      self.ultimate_turbo_modal_context = previous
    end
  end
end
