FROM ruby:2.3.8

# Update apt sources to use archive
RUN echo "deb http://archive.debian.org/debian stretch main" > /etc/apt/sources.list && \
    echo "deb http://archive.debian.org/debian-security stretch/updates main" >> /etc/apt/sources.list

RUN apt-get update && apt-get install -y --allow-unauthenticated \
    build-essential \
    libsqlite3-dev \
    sqlite3 \
    nodejs \
    git \
    libxml2-dev \
    libxslt-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN gem install bundler -v 1.17.3 --no-document

CMD ["bash"]
