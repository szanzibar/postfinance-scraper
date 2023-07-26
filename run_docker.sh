docker build -t postfinance_scraper . 

docker run --name postfinance_scraper --net=host -d postfinance_scraper