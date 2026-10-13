require_relative "../test_helper"
class DevotionalGeneratorTest < ActiveSupport::TestCase
  test "selects anxiety without accents" do
    result = DevotionalGenerator.call("Tenho ansiedade e preocupação")
    assert_equal "ansiedade", result[:theme]
    assert_equal "Filipenses 4:6-7", result[:verse_reference]
  end
  test "falls back for neutral text" do
    assert_equal "esperanca", DevotionalGenerator.call("Foi um dia normal")[:theme]
  end
  test "rejects invalid length" do
    assert_raises(ArgumentError) { DevotionalGenerator.call(" ") }
    assert_raises(ArgumentError) { DevotionalGenerator.call("x" * 501) }
  end
end
