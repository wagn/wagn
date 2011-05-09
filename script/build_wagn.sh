#!/bin/bash

bundle install

if [ ! -f config/wagn.rb ]; then
  export WAGN_CI_MODE=scratch
  cp config/cruise.wagn.rb config/wagn.rb
else
  export WAGN_CI_MODE=pre
  echo -e "USING PRE-EXISTING DATABASE\n to regenerate, delete config/wagn.rb"
fi

for db_config in config/cruise.*.database.yml; do
  echo -e "~~~~~~\nDATABASE CONFIGURATION: $db_config\n~~~~~~~"
  cp $db_config config/database.yml
  
  if [ $WAGN_CI_MODE = scratch ]; then
    echo "creating wagn database"
    rake wagn:create --trace
    echo "reloading test data"
    env RELOAD_TEST_DATA=true rake db:test:prepare
  fi
  
  rake testspec  
done

