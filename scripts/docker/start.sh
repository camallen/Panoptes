#!/bin/bash -ex

cd /rails_app

if [ -d "/rails_conf/" ]
then
    ln -sf /rails_conf/* ./config/
fi

tmpreaper 7d /tmp/

mkdir -p tmp/pids/
rm -f tmp/pids/*.pid

if [ "$RAILS_ENV" != "development" ]; then
  if [ ! -d public/assets ]
  then
      bundle exec rake assets:precompile
  fi
fi

if [ -f "commit_id.txt" ]; then
  cp commit_id.txt public/
fi

exec /usr/bin/supervisord -c /etc/supervisor/supervisord.conf
