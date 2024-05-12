# wthr
A web app that allows you to enter an address and get back weather for that address. 

[Solution overview](solution-overview.md) is here.

## existing deployment
After the deadline I set up CI/CD to Heroku at https://pleaseallowmeto.helpyourteamlove.life

If you would like to try the app without dealing with local setup (documented below) you can just browse there.

If you want to prove `this code == that site` feel free to submit PRs and I'll approve.  Also if you want to fork and set up your own site on heroku you could:
1. fork
1. create a heroku site
1. use heroku ACM to set up ssl 
1. configure heroku app key and set it up as a secret
1. nit, but change the email in the deploy workflow which is hardcoded to mine.

## installation prereqs
This is what I used, possibly other rails7 versions will work.
1. ruby 3.3.0 (2023-12-25 revision 5124f9ac75) [x86_64-darwin23]
1. rails 7.1.3.2
1. docker > 20.10.21

## setup 

To set up Redis using Docker containers, follow these steps:

1. Ensure Docker is Running
2. Run the Redis Setup Rake Task: ```bundle exec rake redis:setup```

## application installation steps

1. `git clone git@github.com:rhelico/wthr.git`
1. `bundle install`
1. `rails tailwindcss:build` 

## set up env
ok to use .env while developing 
1. create env var for GOOGLE_GEOCODE_API_KEY - must have maps access and $
1. create env var for OPENWEATHERMAP_API_KEY - iirc it's free to start

