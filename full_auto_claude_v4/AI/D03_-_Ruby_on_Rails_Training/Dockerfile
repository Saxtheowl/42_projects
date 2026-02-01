FROM ruby:3.2-slim

RUN apt-get update && apt-get install -y \
    build-essential \
    libsqlite3-dev \
    libxml2-dev \
    libxslt1-dev \
    libyaml-dev \
    nodejs \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY . /app

# Test ex00 - deepthought
RUN cd /app/ex00/deepthought && \
    bundle install && \
    bundle exec rake test

# Test ex01 - ft_wikipedia
RUN cd /app/ex01/ft_wikipedia && \
    bundle install

# Test ex02 - Taillste
RUN cd /app/ex02/Taillste && \
    bundle install && \
    bundle exec rake test

# Test ex03 - HelloWorld
RUN cd /app/ex03/HelloWorld && \
    bundle install && \
    bundle exec rails db:create db:migrate

WORKDIR /app/ex03/HelloWorld

EXPOSE 3000

CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
