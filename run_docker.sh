docker build -t postfinance_scraper . 

docker run --name postfinance_scraper -dp 4000:4000 postfinance_scraper