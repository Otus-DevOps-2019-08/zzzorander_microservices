FROM ruby:2.3-alpine
RUN apk update && apk add build-base && rm -rf /var/cache/apk/* && gem install bundler --no-document

ENV APP_HOME /app
RUN mkdir $APP_HOME
WORKDIR $APP_HOME

ADD Gemfile* $APP_HOME/
RUN bundle install
ADD . $APP_HOME

ENV COMMENT_DATABASE_HOST comment_db
ENV COMMENT_DATABASE comments

CMD ["puma"]
