FROM python:3

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections


RUN echo "deb http://httpredir.debian.org/debian jessie main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb http://httpredir.debian.org/debian jessie-updates main contrib non-free" >> /etc/apt/sources.list && \
  echo "deb http://security.debian.org/ jessie/updates main contrib non-free" >> /etc/apt/sources.list && \
  apt-get -q update && \
  apt-get install -y git libxml2-dev libxslt-dev libyaml-dev liblapack-dev postgresql-client unrar npm nodejs-legacy ruby ruby-compass && \
  apt-get clean && \
  mkdir -p /app && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /tmp/*

RUN git clone -b development-postgres https://github.com/samtayuk/pynab.git /app/pynab && \
  sed -i '$ d' /app/pynab/pynab/__init__.py && \
  pip install -r /app/pynab/requirements.txt && \
  pip install waitress && \
  cd /app/pynab/webui; npm install && \
  cd /app/pynab/webui; npm install -g grunt-cli bower && \
  cd /app/pynab/webui; bower install --allow-root && \
  cd /app/pynab/webui; grunt build

add config.py /app/pynab/

WORKDIR /app/pynab

CMD waitress-serve --port=8000 api:app
