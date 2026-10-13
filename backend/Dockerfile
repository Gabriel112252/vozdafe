FROM ruby:3.3-slim
WORKDIR /app
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libyaml-dev && rm -rf /var/lib/apt/lists/*
COPY Gemfile ./
RUN bundle install
COPY . .
ENV RAILS_ENV=production PORT=3000
EXPOSE 3000
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "3000"]
