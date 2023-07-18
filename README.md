# PostfinanceScraper

Scrapes Postfinance.ch to log in and download transaction export. Cleans up exported csv, then imports to firefly_iii.

## Setup

Set copy .env.template to .env and set variables

## Debugging

remove `--headless` args in `postfinance_scarper.ex` to watch scraping in a chrome window.
