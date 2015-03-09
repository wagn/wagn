#!/bin/bash

VER=1.15.pre
DATABASE=mysql
RVER=3.2.16
DBCFG=../database.yml.local2
#SEEDSQL=../rdummy_test.sql
GEMFILE=../Gemfile.eng_deck
RAKEFILE=../Rakefile.eng_deck
APPLICATION=../application_rb.eng_deck
REPO_DIR=`pwd`
TEST_WORK=${REPO_DIR}/test_work
cd wagn/
gem build wagn.gemspec
mv *.gem ${REPO_DIR}/card/
cd ${REPO_DIR}/decko-rails
gem build decko.gemspec
mv *.gem ${REPO_DIR}/card/
cd ${REPO_DIR}/card
gem build card.gemspec
gem install *-${VER}.gem
cd $TEST_WORK
bundle exec rails -v
echo Generate a rails app
bundle exec rails new test_wagn_rails --skip-bundle --database=$DATABASE
cd test_wagn_rails
echo "Diff config (should only show necessary edits after rails new above)"
diff ${GEMFILE} Gemfile
#diff ${RAKEFILE} Rakefile
#diff ${APPLICATION} config/application.rb
echo "Add config"
cp ${GEMFILE} Gemfile
echo "bundle install"
bundle install
# load seed db (customize to your database.yml)
#echo "Load seed db (enter the pw)"
#mysql -u decko_user -p mdummy_test < ${SEEDSQL}
# copy db config (populate .local with you user/pw)
cp ${DBCFG} config/database.yml
RAILS_ENV=test bundle exec rake db:create --trace
echo "seed database"
RAILS_ENV=test bundle exec rake wagn:seed --trace
#echo "migrating"
#RAILS_ENV=test bundle exec rake db:migrate --trace
#RAILS_ENV=test bundle exec rake wagn:migrate --trace
#RAILS_ENV=development bundle exec rake db:migrate --trace
#RAILS_ENV=development bundle exec rake wagn:migrate --trace
