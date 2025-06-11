# DotiDot Scraper API

A lightweight Ruby on Rails API that scrapes web pages based on provided CSS selectors and meta tags, optimized with caching.

## Features

- Fetch HTML content from a given URL
- Extract elements using CSS selectors
- Extract `meta` tags by `name`
- Cache HTML downloads to minimize redundant requests
- Graceful error handling

## Requirements

- Ruby 3.4+
- Rails 8+

## Installation

```bash
git clone https://github.com/Shongi/dotidot_scraper.git
cd dotidot_scraper
bundle install
```

## Running the Server

```bash
bin/rails server
```

## API Usage

### Endpoint

**POST** `/data`

### Request Body

```json
{
  "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
  "fields": {
    "price": ".price-box__primary-price",
    "rating_count": ".ratingCount",
    "rating_value": ".ratingValue",
    "meta": [ "keywords", "twitter:image" ]
  }
}
```

### Sample Response

```json
{
  "price": "15 990,-",
  "rating_count": "25 hodnocení",
  "rating_value": "4,9",
  "meta": {
    "keywords": "AEG,7000,ProSteam®,LFR73964CC,Automatické pračky...",
    "twitter:image": "https://image.alza.cz/products/...jpg"
  }
}
```

## Testing

Tests are written using RSpec.

```bash
bin/rspec
```

Caching is tested using `Rails.cache`, and external HTTP calls are mocked.

## Manual Testing

You can test the scraper endpoint manually using **Curl** or **Postman** by sending a **POST** request with a JSON body, make sure the server is running.

**Curl:**

```bash
curl -X POST http://localhost:3000/data \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
    "fields": {
      "price": ".price-box__primary-price",
      "rating_count": ".ratingCount",
      "rating_value": ".ratingValue",
      "meta": ["keywords", "twitter:image"]
    }
  }'
```

**Postman:**
- set the method to **POST**
- set the URL to http://localhost:3000/data
- set the body as raw JSON with the example JSON from the **Request Body** section

## Notes

- Caching is done with Rails' built-in cache store.
- Meta tags are matched using the `name` attribute only.

## Code Structure

- ScraperController: Single endpoint controller
- ScrapePage: Command object encapsulating the scraping logic
- Tests in spec/
