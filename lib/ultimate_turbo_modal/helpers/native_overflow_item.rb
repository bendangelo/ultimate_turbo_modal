# frozen_string_literal: true

module UltimateTurboModal
  module Helpers
    module NativeOverflowItem
      DEFAULT_SECTION = "actions"

      def self.normalize(item)
        item = item.symbolize_keys
        {
          key: item[:key].to_s,
          label: item[:label],
          icon: item[:icon],
          path: item[:path] || item[:url],
          method: (item[:method] || "get").to_s,
          section: item[:section] || DEFAULT_SECTION,
          target: item[:target],
          confirm: item[:confirm],
          destructive: item.key?(:danger) ? item[:danger] == true : item[:destructive] == true,
          turbo_frame: item[:turbo_frame],
          submit_form: item[:submit_form] || item[:form],
          submit_name: item[:submit_name] || item[:name],
          submit_value: item[:submit_value] || item[:value]
        }.compact
      end
    end
  end
end
