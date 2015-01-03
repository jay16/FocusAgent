#!/bin/bash
# init new environment

# switch to root and execute this bash script
# `bundle install --local`

gem install haml -v 4.0.5
gem install sinatra -v 1.4.5
gem install settingslogic -v 2.0.9
gem install sinatra-contrib -v 1.4.2
gem install sinatra-flash -v 0.3.0
gem install sass -v 3.3.7
gem install unicorn -v 4.8.3
gem install rake -v 10.3.2
gem install net-ssh -v 2.7.0
gem install net-scp 1.2.1
yum install -y tree git
chown -R webmail:webmail ./
