
su - app sh -c 'cd /home/app/; tar -xzvf /tmp/build/wagnapp.tgz'

cd /work
cp /home/app/wagnapp/Gemfile .
ls -l
pwd
bundle install

mv /tmp/build/env.conf /etc/nginx/main.d/env.conf
mv /tmp/build/webapp.conf /etc/nginx/sites-enabled/webapp.conf
rm /etc/service/nginx/down
