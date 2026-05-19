geocoder_config = {
  timeout: 3,
  units: :km,
  http_headers: {
    "User-Agent": "wenkangchen4@gmail.com, take-home assignment"
  }
}

unless Rails.env.test?
  geocoder_config[:cache] = Geocoder::CacheStore::Generic.new(Rails.cache, {})
  geocoder_config[:cache_options] = {
    expiration: 12.hours
  }
end

Geocoder.configure(geocoder_config)
