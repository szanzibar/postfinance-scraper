docker build -t postfinance_scraper .

docker stop postfinance_scraper &>/dev/null
docker rm postfinance_scraper &>/dev/null

docker run --name postfinance_scraper --restart unless-stopped --net=host -d postfinance_scraper