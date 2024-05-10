# wthr
A simple web app that allows you to enter an address and get back weather for that address

## important components
```
app/
└── config/
│   └── initializers/
│       └── redis_docker.rb
└── services/
    └── weather/
    │   ├── weather_provider.rb
    │   ├── weather_service.rb
    │   └── weather_fetcher.rb
    ├── address/
    │   ├── address_provider.rb
    │   └── address_service.rb
    └── cache/
        ├── base_fetcher.rb
        └── fetching_cache_service.rb
```
### redis_docker.rb
builds redis in docker

### WeatherProvider
Encapsulates our specific weather implementation of using Open Weather.  

Could be named OpenWeatherWeatherProvider, an implementation of BaseWeatherProvider which I also didn't have to code yet, but we should earn that plugability when Product says we are going multi-provider.  An easy refactor with much cheaper dev-hours we have in the future.  

### WeatherService
Knows how to get weather using a provider, and to cache it.

### WeatherFetcher
Implements BaseFetcher which is the interface the FetchingCacheService uses to implement read-through cache.  
- Takes a lat, lon, and WeatherProvider at initialization.
- Provides a key to cache by
- Providers a fetch that it translates to weather_provider.current_weather

### AddresProvider
Encapsulates our specific address lookup of using Google Map API.

Could be named GoogleMapAddressProvider, an implementation of BaseAddressProvider which I also didn't have to code yet, but we should earn that plugability when Product says we are going multi-provider.  An easy refactor with much cheaper dev-hours we have in the future. 

### AddressService
Knows how to get an address from a provider.

### BaseFetcher
Defines the interface that the FetchingCacheService uses to implement read through.  

### FetchingCacheService
Take an implementation of BaseFetcher, gets a key from it to check cache.  Failing to find it calls fetch() upon it to get cacheable data.  Sticks that data in Redis.  Either way, returns data.


## Assignment Requirements
[x] Use rails
[x] Accept an address as input
[x] Retrieve forecast data for the given address. This should include, at minimum, the current temperature 
[ ] (Bonus points - Retrieve high/low and/or extended forecast)
[x] Display the requested forecast details to the user
[...] Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.


## Assignment Quality Requirements
[ ] Functionality is a priority over form
[ ] Unit Tests (#1 on the list of things people forget to include – so please remember, treat this as if it were true production level code, do not treat it just as an exercise),
[ ] Detailed Comments/Documentation within the code, 
[x] ...also have a README file
[x] Include *Decomposition* of the Objects in the Documentation
[x] Design Patterns (if/where applicable)
[x] Scalability Considerations (if applicable)
[x] Naming Conventions (name things as you would name them in enterprise-scale production code environments)
[x] Encapsulation, (don’t have 1 Method doing 55 things)
[?] Code Re-Use, (don’t over-engineer the solution, but don’t under-engineer it either)
[ ] and any other industry Best Practices.
[x] Remember to Include the UI ***

## Current PoR
[x] generate rails boilerplate
[x] create basic ux framework
[x] create interactive page with input
[x] address lookup
[x] weather lookup
[x] refactor logic for enterprise
[x] cache
[ ] Quality Requirements ^^^
[ ] Enterprise Delight
[ ] Delight and Style

## Strategy
1. get requirements done first, then Quality requirements, then add delight
1. use Open Weather 
1. use Google geo api to get lat / lon 
1. cache in Redis  
1. implement Redis via docker so setup for others easy

## Enterprise Delight

1. Throttling
1. Telemetry
1. Admin Panel
1. Alerts

## Fancy Delight

[ ] get weather for IP upon first visit
[ ] map
[x] autocomplete
[ ] tiles showing weather at previous searches
[ ] gui browse time
[ ] LLM to allow for NL request

## installation prereqs
1. ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]
1. rails 7.1.3.2
1. postgres 15
1. docker > 20.10.21

## setup 

To set up Redis using Docker containers, follow these steps:

1. Ensure Docker is Running
2. Run the Redis Setup Rake Task:
```
bundle exec rake redis:setup
```

## application installation steps

1. `git clone git@github.com:rhelico/wthr.git`
1. `bundle install`
1. `rails tailwindcss:build` 
1. `rails db:create db:migrate`

## set up env
ok to use .env while developing 
1. create env var for GOOGLE_GEOCODE_API_KEY - must have maps access and $
1. create env var for OPENWEATHERMAP_API_KEY - iirc it's free to start


