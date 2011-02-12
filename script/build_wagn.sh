#!/bin/bash

cp config/cruise.env.rb config/environment.rb

if [ ! -f config/wagn.rb ]; then
  cp config/cruise.wagn.rb config/wagn.rb

  git update-index --assume-unchanged .gitignore config/environment.rb
  git config --global alias.co checkout

  # standard install
  git submodule update 
  git submodule init

  for db_config in config/cruise.*.database.yml; do
    cp $db_config config/database.yml
    if [ -f config/cruise.schema.rb ]; then
      cp config/cruise.schema.rb db/schema.rb
    fi

    rake gems:install
    rake wagn:create --trace
    rake db:migrate --trace
    env RAILS_ENV=test rake db:create

    # setup for tests
    env RAILS_ENV=test rake gems:install
    env RAILS_ENV=cucumber rake gems:install
    env RELOAD_TEST_DATA=true rake db:test:prepare
  done
fi

for db_config in config/cruise.*.database.yml; do
  cp $db_config config/database.yml
  echo DB: $db_config

  echo -n "Starting test/* at: "; date
  if ! env RAILS_ENV=test rake test --trace 2>&1 | tee tst.out; then
    exit $?
  fi

  echo -n "Starting spec at: "; date
  if ! env RAILS_ENV=test rake spec --trace 2>&1 | tee spc.out; then
    exit $?
  fi

  echo -n "Starting cucumber at: "; date
  if ! env RAILS_ENV=test rake cucumber --trace 2>&1 | tee cuc.out; then
    exit $?
  fi
done
