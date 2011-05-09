#!/bin/bash

bundle install

if [ ! -f config/wagn.rb ]; then
  export WAGN_CI_MODE=scratch
  cp config/cruise.wagn.rb config/wagn.rb
else
  echo -e "USING PRE-EXISTING DATABASE\n to regenerate, delete config/wagn.rb"
fi

for db_config in config/cruise.*.database.yml; do
  echo -e "~~~~~~\nDATABASE CONFIGURATION: $db_config\n~~~~~~~"
  
  if [ $WAGN_CI_MODE = scratch ]; then
    cp $db_config config/database.yml
    echo "creating wagn database"
    rake wagn:create --trace
#    env RAILS_ENV=test rake db:create
    echo "reloading test data"
    env RELOAD_TEST_DATA=true rake db:test:prepare
  fi
  
  rake testspec  
done

