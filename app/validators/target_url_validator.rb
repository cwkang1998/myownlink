class TargetUrlValidator < ActiveModel::EachValidator
  SHORT_URL_PATH_PATTERN = %r{\A/[0-9A-Za-z]{1,15}\z}
  DEFAULT_SHORT_URL_HOSTS = %w[localhost 127.0.0.1 ::1].freeze

  def validate_each(record, attribute, value)
    return if value.blank?

    uri = parse_uri(value)

    unless valid_http_url?(uri)
      record.errors.add(attribute, "must be a valid URL")
      return
    end

    return unless shortened_url?(uri)

    record.errors.add(attribute, "must not be another shortened URL")
  end

  private

  def parse_uri(value)
    URI.parse(value)
  rescue URI::InvalidURIError
    nil
  end

  def valid_http_url?(uri)
    uri.present? && uri.host.present? && uri.scheme.in?(%w[http https])
  end

  def shortened_url?(uri)
    SHORT_URL_PATH_PATTERN.match?(uri.path) && short_url_hosts.include?(uri.host.downcase)
  end

  def short_url_hosts
    [
      ENV["APP_HOST"],
      Rails.application.routes.default_url_options[:host],
      *DEFAULT_SHORT_URL_HOSTS
    ].compact_blank.map(&:downcase).uniq
  end
end
