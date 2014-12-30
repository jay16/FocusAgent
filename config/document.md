# Document

agent server with deploy(monitor/logger/rake)/api command explain.

## Deploy

### git

	````
	# situation 1: without git init
	git clone https://github.com/jay16/focus_mail_agent.git
	
	# situation 2：code already exist
	cd app_root_path
	git reset --hard HEAD
	git pull origin master
	
	# be sure under webmail
	# or execute 
	chown -R webmail:webmail app_root_path
	````
	
### gem

	````
	cd app_root_path
	bundle install --local
	# gem install 'notfound-gem' when abort
	````

### generate

	````
	# mkdir necessary direcotries and generate config tmp files
	bundle exec rake agent:deploy
	# tell you what omit 
	bundle exec rake agent:check
	# clear test files after test with rspec
	bundle exec rake agent:clear
	````
	
### rspec

	````
	# generate email files like focus_mail server
	bundle exec rspec spec/controllers
	# view generate files
	tree public/{openapi,mailtem}
	
	# download/tar extract/move to fake mailgates/wait
	bundle exec rake agent:main RACK_ENV=test
	tree public/mailgates
	````

### nohup

	````
	cd app_root_path
	/bin/sh nohup.sh {start|stop|status}
	
	# ps: rake task called by nohup.sh **every 5 seconds**
	````
	
### unicorn

	````
	cd app_root_path
	/bin/sh unicorn.sh {start|stop}
	
	# view browser
	http://localhost:3456
	# view logs
	tail -f log/*
	
	# ps: nohup.sh called by unicorn.sh
	````
	
### crontab

	````
	# crontab operation list
	# crontab @jobs command write in Rakefile
	bundle exec rake crontab:list     # list all crontab jobs
	bundle exec rake crontab:add      # add @jobs with check exist
	bundle exec rake crontab:remove   # remove @jobs
	bundle exec rake crontab:exist    # check whether @job exist
	bundle exec rake crontab:jobs      # print @jobs command
	
	# don't loose with crontab @jobs workly
	# bundle/rake/unicorn command may run normally with hand
	# but not ok with bash script called by crontab
	
	# check it with below steps:
	cd app_root_path
	bundle exec rake crontab:add
	/bin/sh unicorn.sh stop
	tail -f log/*
	
	# it's ok when crontab @jobs startup unicorn and nohup successfully.
	# best for browser operate.
	
	# ps: crontab @jobs execute unicorn.sh {stop|start} when unicorn and nohup not all ok **every minute**.
	````

### 1->2->3

	````
	# **point**
	su - webmail
	
	cd app_root_path
	bundle install --local
	
	# RACK_ENV for really environment
	bundle exec rake agent:deploy RACK_ENV=production
	bundle exec rake agent:check RACK_ENV=production
	
	# test with rspec can put here when necessay
	# rspec generate email file is not correct, only check download/tar extract/move
	
	# should over when lucklly.
	bundle exec rake crontab:add
	tail -f log/*
	
	# when command not found Bundler/Unicorn
	./unicorn.sh stop
	./unicorn.sh start
	````

## API

### api list

	````
	# download trigger/download/move data
	# params:
	#     token: necessary
	#     timestamp: optional,yyyymmdd, default today
	GET /cpanel/open/data
	
	# download mailgates log file
	# params:
	#     token: necessary
	#     filename: optional,default "mgmailerd.log"
	GET /cpanel/open/log
	
	# download mailgates archived log file
	# params:
	#     token: necessary
	#     timestamp: optional,yyyymmdd, default today(response: file not exist)
	GET /cpanel/open/archived
	
	
	# get webapp/nohup/crontab run state
	# params:
	#     token: necessary
	GET /cpanel/open/process
	````
	

generated at 2014/12/30 by jay

