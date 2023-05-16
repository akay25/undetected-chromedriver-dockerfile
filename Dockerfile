FROM python:3.10-buster

# Default envs and args
ENV PYTHONUNBUFFERED 1
ENV SCREEN_GEOMETRY "1360x768x24"
ENV DISPLAY :20.0

# Ports
EXPOSE 5900

# Installing pre-requisite softwares
RUN apt-get update && \
    apt-get install -y apt-transport-https && \
    apt-get install -y apt wget && \
    apt-get install -y apt fping && \
    apt-get install -y apt-utils && \
    apt-get install -y debconf-utils && \
    apt-get install -y build-essential && \
    apt-get install -y gcc && \
    apt-get install -y g++

# Setting up chrome and chromedriver
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add - \
    && echo "deb http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google-chrome.list \
    && apt-get update -qqy \
    && apt-get -qqy install \
    ${CHROME_VERSION:-google-chrome-stable} \
    && rm /etc/apt/sources.list.d/google-chrome.list \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

RUN if [ -z "$CHROME_DRIVER_VERSION" ]; \
    then CHROME_MAJOR_VERSION=$(google-chrome --version | sed -E "s/.* ([0-9]+)(\.[0-9]+){3}.*/\1/") \
    && NO_SUCH_KEY=$(curl -ls https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION} | head -n 1 | grep -oe NoSuchKey) ; \
    if [ -n "$NO_SUCH_KEY" ]; then \
    echo "No Chromedriver for version $CHROME_MAJOR_VERSION. Use previous major version instead" \
    && CHROME_MAJOR_VERSION=$(expr $CHROME_MAJOR_VERSION - 1); \
    fi ; \
    CHROME_DRIVER_VERSION=$(wget --no-verbose -O - "https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${CHROME_MAJOR_VERSION}"); \
    fi \
    && echo "Using chromedriver version: "$CHROME_DRIVER_VERSION \
    && wget --no-verbose -O /tmp/chromedriver_linux64.zip https://chromedriver.storage.googleapis.com/$CHROME_DRIVER_VERSION/chromedriver_linux64.zip \
    && rm -rf /opt/selenium/chromedriver \
    && unzip /tmp/chromedriver_linux64.zip -d /opt/selenium \
    && rm /tmp/chromedriver_linux64.zip \
    && mv /opt/selenium/chromedriver /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
    && chmod 755 /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION \
    && ln -fs /opt/selenium/chromedriver-$CHROME_DRIVER_VERSION /usr/bin/chromedriver

# Set up display server
# Install xvfb, fonts, Fluxbox (window manager), x11vnc
RUN apt update && apt -yqq install xvfb fonts-ipafont-gothic xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic fluxbox x11vnc supervisor

RUN mkdir -p ~/.vnc
RUN mkdir -p /var/log/supervisor

# Configure Supervisor 
ADD ./dockerfiles/supervisor/conf.d /etc/supervisor/conf.d

RUN x11vnc -storepasswd selenium ~/.vnc/passwd

# Copying src and Pipfile
COPY Pipfile /app/
COPY Pipfile.lock /app/
WORKDIR /app

# Installing required python libraries
RUN pip install pipenv
RUN pipenv install --system --deploy

# Source code
COPY src/ /app

CMD (rm /var/run/supervisor.sock || true) && /usr/bin/supervisord -c /etc/supervisor/supervisord.conf && python main.py
