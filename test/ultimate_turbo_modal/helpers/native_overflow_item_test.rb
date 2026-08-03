# frozen_string_literal: true

require "test_helper"

class UltimateTurboModalNativeOverflowItemTest < Minitest::Test
  def test_normalizes_minimal_hash
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "edit", label: "Edit"})

    assert_equal "edit", result[:key]
    assert_equal "Edit", result[:label]
    assert_equal "actions", result[:section]
    assert_equal "get", result[:method]
    assert_equal false, result[:destructive]
  end

  def test_coerces_symbol_keys
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({"key" => "delete", "label" => "Delete"})

    assert_equal "delete", result[:key]
    assert_equal "Delete", result[:label]
  end

  def test_maps_danger_to_destructive
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "delete", label: "Delete", danger: true})

    assert_equal true, result[:destructive]
  end

  def test_maps_destructive_directly
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "delete", label: "Delete", destructive: true})

    assert_equal true, result[:destructive]
  end

  def test_danger_takes_precedence_over_destructive
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "delete", label: "Delete", danger: false, destructive: true})

    assert_equal false, result[:destructive]
  end

  def test_submit_name_falls_back_to_name
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "print", label: "Print", name: "print_btn"})

    assert_equal "print_btn", result[:submit_name]
  end

  def test_submit_name_takes_precedence
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "print", label: "Print", submit_name: "override", name: "fallback"})

    assert_equal "override", result[:submit_name]
  end

  def test_submit_value_falls_back_to_value
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "approve", label: "Approve", value: "yes"})

    assert_equal "yes", result[:submit_value]
  end

  def test_submit_value_takes_precedence
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "approve", label: "Approve", submit_value: "override", value: "fallback"})

    assert_equal "override", result[:submit_value]
  end

  def test_path_falls_back_to_url
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "view", label: "View", url: "/items/1"})

    assert_equal "/items/1", result[:path]
  end

  def test_path_takes_precedence_over_url
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "view", label: "View", path: "/items/2", url: "/items/1"})

    assert_equal "/items/2", result[:path]
  end

  def test_submit_form_falls_back_to_form
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "save", label: "Save", form: "my-form"})

    assert_equal "my-form", result[:submit_form]
  end

  def test_submit_form_takes_precedence
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "save", label: "Save", submit_form: "override-form", form: "fallback-form"})

    assert_equal "override-form", result[:submit_form]
  end

  def test_compact_removes_nil_values
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "simple", label: "Simple"})

    refute result.key?(:icon)
    refute result.key?(:target)
    refute result.key?(:confirm)
    refute result.key?(:turbo_frame)
    refute result.key?(:submit_form)
    refute result.key?(:submit_name)
    refute result.key?(:submit_value)
  end

  def test_preserves_optional_fields_when_provided
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({
      key: "full", label: "Full", icon: "pencil", target: "_blank",
      confirm: "Sure?", turbo_frame: "modal", submit_form: "f",
      submit_name: "n", submit_value: "v"
    })

    assert_equal "pencil", result[:icon]
    assert_equal "_blank", result[:target]
    assert_equal "Sure?", result[:confirm]
    assert_equal "modal", result[:turbo_frame]
    assert_equal "f", result[:submit_form]
    assert_equal "n", result[:submit_name]
    assert_equal "v", result[:submit_value]
  end

  def test_custom_section
    result = UltimateTurboModal::Helpers::NativeOverflowItem.normalize({key: "share", label: "Share", section: "share_sheet"})

    assert_equal "share_sheet", result[:section]
  end
end
