module Base62
  ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ".freeze
  BASE = ALPHABET.length
  INDEX = ALPHABET.chars.each_with_index.to_h.freeze
  # Since we currently mainly using id for generating the code
  # it should not easily exceed the max length of 15.
  MAX_LENGTH = 15
  MAX_SUPPORTED_INT = BASE ** MAX_LENGTH

  class Error < StandardError; end

  module_function

  def encode(number)
    integer = Integer(number)
    raise ArgumentError, "number must be non-negative" if integer.negative?
    raise ArgumentError, "number is too large, must be less than #{MAX_SUPPORTED_INT}" if integer >= MAX_SUPPORTED_INT
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
    raise ArgumentError, "value must have length less than #{MAX_LENGTH} characters" if string.length > MAX_LENGTH

    string.each_char.reduce(0) do |number, char|
      digit = INDEX.fetch(char) { raise Error, "invalid Base62 character: #{char.inspect}" }

      (number * BASE) + digit
    end
  end
end
