Geocoder.configure(
  lookup: :google,
  api_key: ENV['GOOGLE_GEOCODE_API_KEY'],
  use_https: true,
  units: :km
)