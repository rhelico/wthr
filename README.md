# wthr
A web app that allows you to enter an address and get back weather for that address. 

[Solution overview](solution-overview.md) is here.

## installation prereqs
This is what I used, possibly other rails7 versions will work.
1. ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]
1. rails 7.1.3.2
1. postgres 15 
1. docker > 20.10.21

## setup 

To set up Redis using Docker containers, follow these steps:

1. Ensure Docker is Running
2. Run the Redis Setup Rake Task: ```bundle exec rake redis:setup```

## application installation steps

1. `git clone git@github.com:rhelico/wthr.git`
1. `bundle install`
1. `rails tailwindcss:build` 
1. `rails db:create db:migrate`

## set up env
ok to use .env while developing 
1. create env var for GOOGLE_GEOCODE_API_KEY - must have maps access and $
1. create env var for OPENWEATHERMAP_API_KEY - iirc it's free to start

