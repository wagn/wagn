#!/bin/bash

VER=1.15.pre
DBCFG=../database.yml.local
SEEDSQL=../mdummy_test.sql
cd wagn/
gem build wagn.gemspec
mv *.gem ../card/
cd ../decko-rails
gem build decko.gemspec
mv *.gem ../card/
cd ../card
gem build card.gemspec
gem install *-${VER}.gem
cd ../test_work
rbenv which wagn
echo Generate a wagn app
wagn new test_wagn_app -c --gem-path='../../'
cd test_wagn_app
# load seed db (customize to your database.yml)
echo "Load seed db (enter the pw)"
mysql -u decko_user -p mdummy_test < ${SEEDSQL}
# copy db config (populate .local with you user/pw)
cp ${DBCFG} config/database.yml
echo "migrating"
#RAILS_ENV=test bundle exec rake db:migrate --trace
RAILS_ENV=test bundle exec rake wagn:migrate --trace
#RAILS_ENV=development bundle exec rake db:migrate --trace
#RAILS_ENV=development bundle exec rake wagn:migrate --trace
