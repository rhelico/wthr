
# Solution Overview
This is a take home test.  The assignment was to build a web app that allows you to enter an address and get back weather for that address.

Results must be cached by zipcode for 30 minutes.

Qualitatively, it should be done in an enterprise 
manner.

## approach
- rails7 with some stimulus and tailwind for styling
- Google Maps API for address lookup
- OpenWeather via http call to URL
- redis for cache with custom handlers (vs. Rails.Cache)
- local docker to simplify redis config for the purposes of this demo
- separation of concerns via services: `address`, `weather`, and `cache`, 
- futher decomposition within each service via helper classes

## challenges

### cache strategy
I used Google Maps API which has a robust address lookup.  You can type in non-addresses such as "The Louvre" or "McMurdo Sound" and get back a lat/lon, _but not a postal code_.  This presents a problem for caching.  Lot's of weather happening at `null`.

To mitigate this I implememnted a backup strategy to use a geohash of lat/lon when postal code is null.  I used a precision of 5 which is about 25Km diameter area as an approsimation of zip code.

### Redis for cache

There is a rakefile that builds a dev instance of redis and an initializer that sets it up for the app.  An enterprise would have distributed infra for cache, probably redis, and support for dev like this.  I toyed with building a cluster but had trouble getting the cluster to work with three docker containers.

30 min expiry is set in Redis upon caching.

To be enterprise-y, I built a generic read-through cache layer (the `FetchingCacheService`) on top of Redis. 

It would have been easier to extend Rails cache to do this.  I pretended there was some big company complexity that required this.  

The read-through cache takes a fetcher object and provides a base class to define the contract.  A fetcher implementation requires that it provide a key to cache under, and a fetch to go get data when there is no cache.  The service caches fetched data to implement the read-through.  

It also annotates the data as cached or not, to fulfill the requirement of indicating when the data comes from cache.

### Oject decomposition

I abstracted the address provider from the service, presuming we could plug in other providers.

Not sure how enterprise-y I was supposed to go, I created a more abstract example with the weather provider, and
used a base class and a specific WeatherProviderOpenWeather implementation of that class.  

The Weather module also implments the WeatherFetcher as the mechanism to cache the weather data in the caching service.


## important files are here
```
app/
└── services/
    ├── address/
    │   ├── address_provider.rb
    │   └── address_service.rb
    ├── cache/
    │   ├── base_fetcher.rb
    │   └── fetching_cache_service.rb
    └── weather/
        ├── base_weather_provider.rb
        ├── weather_fetcher.rb
        ├── weather_provider_open_weather.rb
        └── weather_service.rb
```
