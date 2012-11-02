#!/bin/bash

export DISPLAY=:99.0
bundle install --path ../gems

if [ ! -f config/wagn.yml ]; then
  export WAGN_CI_MODE=scratch
  cp config/cruise/wagn.yml config/wagn.yml
else
  export WAGN_CI_MODE=pre
  echo -e "USING PRE-EXISTING DATABASE\n to regenerate, delete config/wagn.yml"
fi

for db_config in config/cruise/*.database.yml; do
  echo -e "~~~~~~\nDATABASE CONFIGURATION: $db_config\n~~~~~~~"
  cp $db_config config/database.yml

  if [ $WAGN_CI_MODE = scratch ]; then
    echo "creating wagn database"
    bundle exec rake wagn:create --trace
    echo "reloading test data"
    env RELOAD_TEST_DATA=true bundle exec rake db:test:prepare
  fi

  bundle exec rake test
  bundle exec rake spec
  bundle exec cucumber
done

