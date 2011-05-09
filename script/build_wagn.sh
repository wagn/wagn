bundle install

# will not re-create databases from scratch if config/wagn.rb is in place 
if [ ! -f config/wagn.rb ]; then
  cp config/cruise.wagn.rb config/wagn.rb

  git update-index --assume-unchanged .gitignore #config/environment.rb
  git config --global alias.co checkout


  for db_config in config/cruise.*.database.yml; do
    cp $db_config config/database.yml
    #if [ -f config/cruise.schema.rb ]; then
    #  cp config/cruise.schema.rb db/schema.rb
    #fi

    rake wagn:create --trace

    env RAILS_ENV=test rake db:create

    # setup for tests
    env RELOAD_TEST_DATA=true rake db:test:prepare
  done
fi

for db_config in config/cruise.*.database.yml; do
  cp $db_config config/database.yml
  echo -e "\n\n"
  echo DATABASE CONFIGURATION: $db_config
  echo -e "\n\n"

  rake testspec
#  echo -n "Starting test/* at: "; date
#  if ! env RAILS_ENV=test rake test --trace 2>&1     |./script/test_filter | tee tst.out; then
#    exit $?
#  fi

#  echo -n "Starting spec at: "; date
#  if ! env RAILS_ENV=test rake spec --trace 2>&1     |./script/test_filter | tee spc.out; then
#    exit $?
#  fi

#  echo -n "Starting cucumber at: "; date
#  if ! env RAILS_ENV=test rake cucumber --trace 2>&1 |./script/test_filter | tee cuc.out; then
#    exit $?
#  fi
done