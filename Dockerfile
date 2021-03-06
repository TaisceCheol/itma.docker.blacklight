# A Dockerfile for Blacklight
FROM ubuntu:14.04

MAINTAINER Piaras Hoban <piaras.hoban@itma.ie>

# Install Ruby, nodejs and postgresql
RUN apt-get update
RUN apt-get install git-core curl zlib1g-dev build-essential libssl-dev libreadline-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt1-dev libcurl4-openssl-dev  python-software-properties libffi-dev liblzma-dev libgmp-dev -y
RUN apt-get install libgdbm-dev libncurses5-dev automake libtool bison libffi-dev -y
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -L https://get.rvm.io | bash -s stable
RUN /bin/bash -c "source /usr/local/rvm/scripts/rvm"
RUN /bin/bash -l -c "rvm install 2.2.3"
RUN /bin/bash -l -c "rvm use 2.2.3 --default"
RUN curl -sL https://deb.nodesource.com/setup_4.x | sudo -E bash -
RUN apt-get install -y nodejs
RUN apt-get install -y libpq-dev
ENV PATH /usr/local/rvm/gems/ruby-2.2.3/bin:/usr/local/rvm/gems/ruby-2.2.3@global/bin:/usr/local/rvm/rubies/ruby-2.2.3/bin:$PATH:/usr/local/rvm/bin

RUN useradd -ms /bin/bash blacklight

RUN gem install bundler
RUN gem install rails
RUN bundle config --global silence_root_warning 1

WORKDIR /opt/

RUN rails new blacklight_app -d postgresql

WORKDIR /opt/blacklight_app

ADD Gemfile /opt/blacklight_app/Gemfile
ADD Gemfile.lock /opt/blacklight_app/Gemfile.lock
RUN bundle install 

RUN rails generate blacklight:install --devise
# RUN rake "db:migrate"

COPY ./src/controllers/ app/controllers/
COPY ./src/views/ app/views/catalog/
COPY ./src/views/shared app/views/shared/
COPY ./src/sass/blacklight.scss app/assets/stylesheets/
COPY ./src/images/ app/assets/images/
COPY ./src/js/ app/assets/javascripts/

COPY ./src/config/ config/

RUN rails generate blacklight_range_limit:install

ENV SOLR_URL "http://solr:8983/solr/blacklight"

CMD bundle exec rails s -p 3000 -b '0.0.0.0'

