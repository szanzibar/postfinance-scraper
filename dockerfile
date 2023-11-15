# ./Dockerfile

# Extend from the official Elixir image.
FROM elixir:latest

#exclude from watchtower
LABEL com.centurylinklabs.watchtower.enable="false"

# Create app directory and copy the Elixir projects into it.
RUN mkdir /app
COPY . /app
WORKDIR /app
RUN mkdir -p downloads

# Install Hex package manager.
# By using `--force`, we don’t need to type “Y” to confirm the installation.
RUN mix local.hex --force
RUN apt-get update && apt-get install -y inotify-tools

RUN apt-get install -y wget
RUN wget -q https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
RUN apt-get install -y ./google-chrome-stable_current_amd64.deb

# TODO: sometimes the latest version of chrome doesn't yet have a corresponding chromedriver. 
# figure out how to get the latest chromedrive, and then install that version of chrome
# not sure how to download a specific version of chrome directly. Can only find that 
# stable_current url above.
# Alternatively download the latest stable chromedriver assuming a patch version difference doesn't matter.
# Occasionally this could get a major version behind though
RUN CHROME_VERSION=$(google-chrome --product-version) && \
wget https://edgedl.me.gvt1.com/edgedl/chrome/chrome-for-testing/$CHROME_VERSION/linux64/chromedriver-linux64.zip && \
unzip -o chromedriver-linux64.zip -d . && cp ./chromedriver-linux64/chromedriver . && \
rm chromedriver-linux64.zip && rm -r ./chromedriver-linux64 && \
chmod +x ./chromedriver

# Compile the project.
RUN mix do deps.get, deps.compile

CMD ["mix", "phx.server"]

EXPOSE 4000