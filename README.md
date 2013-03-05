# Watchpage

Has a website changed? This small shell script will poll for changes and notify you when they occur.

## Install

1. Checkout repo
2. (optional) tune poll interval in [watchpage.sh](watchpage.sh)

## Usage

1. Initialize a new watcher with `./watchpage.sh mywebsite http://localhost:8000`
2. Rerun the previous command to start watching

## Receiving SMS notifications

1. Register for a [Twilio](https://www.twilio.com) account to receive SMS/Call notifications
2. `cp twilio.config.example twilio.config` and update with values found on your Twilio account