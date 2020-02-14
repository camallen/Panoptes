FROM ruby:2.5-stretch

WORKDIR /rails_app

RUN echo $(grep "VERSION=" /etc/os-release | cut -d "(" -f2 | cut -d ")" -f1) | \
    xargs -i echo "deb http://apt.postgresql.org/pub/repos/apt/ {}-pgdg main" > /etc/apt/sources.list.d/postgresql.list && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

RUN apt-get update && apt-get -y upgrade && \
    apt-get install --no-install-recommends -y \
        git \
        curl \
        supervisor \
        libpq-dev \
        postgresql-client-9.5 \
        tmpreaper \
        libjemalloc1 \
        && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

ENV LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libjemalloc.so.1
ENV RAILS_LOG_TO_STDOUT=true
ENV DISABLE_SPRING=true

ADD ./Gemfile /rails_app/
ADD ./Gemfile.lock /rails_app/

RUN bundle config --global jobs `cat /proc/cpuinfo | grep processor | wc -l | xargs -I % expr % - 1`
RUN bundle install

ADD supervisord.conf.dev /etc/supervisor/conf.d/panoptes.conf
ADD ./ /rails_app

RUN RAILS_ENV=production bundle exec rake assets:precompile

RUN (cd /rails_app && git log --format="%H" -n 1 > commit_id.txt)

CMD /rails_app/scripts/docker/start.sh
