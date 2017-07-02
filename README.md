# cucumber-sentences

[![Gem Version](https://badge.fury.io/rb/cucumber-sentences.svg)](https://rubygems.org/gems/cucumber-sentences)

This gem is a collection of pre-built sentences compatible with cucumber and page-object

## Setup

Require in your `Gemfile`

`````
gem "cucumber-sentences"
`````

Add in your `features/step_definitions/imports.rb`

````
ENV['CUCUMBER_ROOT'] = File.absolute_path('../', File.dirname(__FILE__));
require "cucumber-sentences"
`````

That's all !

## Sentences included

### Pages manipulation

- Given I am on the "([^"]*)"
