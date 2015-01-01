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

## Crash

### git pull

error code:
	
	````
	[webmail@localhost focus_mail_agent]$ git pull 	origin master
	Permission denied (publickey).
	fatal: Could not read from remote repository.

	Please make sure you have the correct access rights
	and the repository exists.
	````
	
solution:
	
	````
	[webmail@ localhost focus_mail_agent]$ git config --local -e
	
	url = git@github.com:jay16/focus_mail_agent.git
	to 
	url = https://github.com/jay16/focus_mail_agent.git
	````

referenced: [提交代码到 GitHub SSH 错误解决方案](!http://www.shenyanchao.cn/blog/2013/09/16/git-ssh-connection/)

### linux environment 

linux bash comand installed by hand, can execute in terminal but not script file

  `alias | grep COMMAND`

add COMMAND basepath into env[PATH] in ~/.bash_profile.

  ````
  # ~/.bash_profile
  PATH="BASEPATH:$PATH"
  ````
    
activate env[PATH].

  `source ~/.bash_profile`

then script file will execute successfully.

**not over**

it's not ok when you execute bash code through ssh!

    + .bash_profile for user environment
    + .bashrc for bash environment, .bash_profile's substitute

### crontab execute base script to startup webserver

1. Bundler/Unicorn/Rake Not found.

reason: 

  `crontab environment variable not same with user.`

solution: 
    
  ````
  source ~/.bashrc 
  source ~/.bash_profile
  ````

2. gem#settinglogic abort when startup webserver

abort text:

  ````
  /lib/settingslogic.rb:102:in 'read': "\xE4" on US-ASCII (Encoding::InvalidByteSequenceError)
  ````
reason:

  around bash environment setting with character setting.

solution:

  ````
  export LANG=zh_CN.UTF-8
  ````

generated at 2014/12/30 by jay
