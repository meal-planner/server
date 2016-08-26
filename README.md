# Meal Planner Server
[![Build Status](https://travis-ci.org/meal-planner/server.svg?branch=master)](https://travis-ci.org/meal-planner/server)
[![Code Climate](https://codeclimate.com/github/meal-planner/server/badges/gpa.svg)](https://codeclimate.com/github/meal-planner/server)
[![Codacy Badge](https://api.codacy.com/project/badge/3626b0cad1564c4ab157ca1875977374)](https://www.codacy.com/app/anatoliy-yastreb/server)
[![Dependency Status](https://gemnasium.com/badges/github.com/meal-planner/server.svg)](https://gemnasium.com/github.com/meal-planner/server)
[![Join the chat at https://gitter.im/meal-planner/public](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/meal-planner/public?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

Meal Planner is an open source recipe recommendation and nutrition balancing service - [meal-planner.org](https://meal-planner.org)

This repository contains RESTful backend implementation.
Resources documentation is available at [docs.meal-planner.org](https://docs.meal-planner.org/)

## Requirements

This application is developed with [Sinatra](https://github.com/sinatra/sinatra) framework and requires [Ruby](https://www.ruby-lang.org/) to run and [Bundler](http://bundler.io/) to install it.

All application data is stored in [ElasticSearch](https://www.elastic.co/products/elasticsearch) instance.
[Bonsai.io](https://bonsai.io) is used to host ElasticSearch clusters.

Twitter OAuth sign in requires persistent storage of request tokens, 
so running [Redis](http://redis.io/) instance is also required.

## Installation

* Install Bundler

  ```
  gem install bundler
  ```
* Run Bundler

  ```
  bundle install
  ```

## Running locally

Start Sinatra with Rack:  

  ```
  rackup -p4567
  ```

## Deployment
This application is deployed at [Heroku](https://heroku.com) and requires [Heroku toolbelt](https://toolbelt.heroku.com).

First, login and create Heroku app:
  ```
  heroku login
  heroku create
  ```
  
It will create new app on Heroku and add `heroku` remote to the repository.
After that deployment can be don with a simple push:
  ```
  git push heroku master
  ```

Configure all required environment variables with `heroku config:set VARIABLE_NAME=VALUE`
See [.env.dist](https://github.com/meal-planner/server/blob/master/.env.dist) file for the list of used environment variables.
