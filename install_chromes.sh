wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
apt-get install -y ./google-chrome-stable_current_amd64.deb
rm google-chrome-stable_current_amd64.deb

CHROME_VERSION=$(google-chrome --product-version)
wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chromedriver-linux64.zip
unzip -o chromedriver-linux64.zip -d .
cp ./chromedriver-linux64/chromedriver .
rm chromedriver-linux64.zip
rm -r ./chromedriver-linux64
chmod +x ./chromedriver