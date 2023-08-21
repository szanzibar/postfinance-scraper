docker build -t postfinance_scraper .

docker stop postfinance_scraper
docker rm postfinance_scraper 2>/dev/null

docker run --name postfinance_scraper --restart unless-stopped --net=host -d postfinance_scraper