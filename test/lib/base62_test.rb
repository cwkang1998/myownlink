require "test_helper"
require "base62"

class Base62Test < ActiveSupport::TestCase
  test "encodes zero" do
    assert_equal "0", Base62.encode(0)
  end

  test "encodes integers using base62 alphabet" do
    assert_equal "1", Base62.encode(1)
    assert_equal "z", Base62.encode(35)
    assert_equal "Z", Base62.encode(61)
    assert_equal "10", Base62.encode(62)
    assert_equal "11", Base62.encode(63)
  end

  test "decodes base62 strings" do
    assert_equal 1, Base62.decode("1")
    assert_equal 35, Base62.decode("z")
    assert_equal 61, Base62.decode("Z")
    assert_equal 62, Base62.decode("10")
    assert_equal 63, Base62.decode("11")
  end

  test "round trips numbers" do
    [ 0, 1, 61, 62, 3_844, 238_327, 14_776_335 ].each do |number|
      assert_equal number, Base62.decode(Base62.encode(number))
    end
  end

  test "rejects negative numbers" do
    error = assert_raises(ArgumentError) { Base62.encode(-1) }

    assert_equal "number must be non-negative", error.message
  end

  test "rejects blank strings" do
    error = assert_raises(ArgumentError) { Base62.decode("") }

    assert_equal "value must not be blank", error.message
  end

  test "rejects invalid base62 characters" do
    error = assert_raises(Base62::Error) { Base62.decode("abc!") }

    assert_equal "invalid Base62 character: \"!\"", error.message
  end
end
