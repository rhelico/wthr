# wthr

## Requirements

- Use rails
- Accept an address as input
- Retrieve forecast data for the given address. This should include, at minimum, the current temperature (Bonus points - Retrieve high/low and/or extended forecast)
- Display the requested forecast details to the user
- Cache the forecast details for 30 minutes for all subsequent requests by zip codes. Display indicator if result is pulled from cache.
- Functionality is a priority over form

## Strategy

1. get requirements done first, then add delight
1. use Open Weather and ruby gem
1. use Radar RESTful API to get lat / lon and show REST / no client
1. cache in db first

## Enterprise Delight

1. Throttling
1. cache in memory
1. Storm King/Queen w/ async pattern

## Fancy Delight

1. get weather for IP upon first visit
1. show map
1. typeahead over REST es mas macho
1. tiles showing weather at previous searches
1. gui browse time
1. LLM to allow for NL request

## installation prereqs

1. ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]
1. rails 7.1.3.2
1. postgres 15

## installation steps

- `git clone git@github.com:rhelico/wthr.git`
- `bundle install`
- `yarn`
- `rails db:create db:migrate`
