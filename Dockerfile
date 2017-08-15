FROM ruby:2.4.1

COPY . /usr/src/app
WORKDIR /usr/src/app
RUN gem install bundler
RUN bundle install

CMD ["rake", "run_consumer"]