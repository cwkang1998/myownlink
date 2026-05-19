module Base62
  ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  BASE = ALPHABET.length
  INDEX = ALPHABET.chars.each_with_index.to_h.freeze

  class Error < StandardError; end

  module_function

  def encode(number)
    integer = Integer(number)
    raise ArgumentError, "number must be non-negative" if integer.negative?

    return ALPHABET[0] if integer.zero?

    encoded = +""
    while integer.positive?
      integer, remainder = integer.divmod(BASE)
      encoded.prepend(ALPHABET[remainder])
    end

    encoded
  end

  def decode(value)
    string = value.to_s
    raise ArgumentError, "value must not be blank" if string.empty?

    string.each_char.reduce(0) do |number, char|
      digit = INDEX.fetch(char) { raise Error, "invalid Base62 character: #{char.inspect}" }

      (number * BASE) + digit
    end
  end
end
