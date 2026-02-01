FROM ruby:3.2

RUN apt-get update -qq && apt-get install -y nodejs npm sqlite3

WORKDIR /app

ENV RAILS_ENV=development

RUN gem install rails -v '7.1.5' bundler

COPY . .

EXPOSE 3000

CMD ["rails", "server", "-b", "0.0.0.0"]
