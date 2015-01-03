## [FocusMailAgent]

### COMMAND

```
    # switch to root
    cd app_root_path
    /bin/sh install.sh

    # **point**
    # switch to webmail
    su - webmail

    # bundle install
    cd app_root_path
    bundle install --local
    
    # RACK_ENV for really environment
    bundle exec rake agent:deploy RACK_ENV=production
    bundle exec rake agent:check RACK_ENV=production
    
    # test with rspec can put here when necessay.
    # rspec generate email file is not correct, 
    # only check download/tar extract/move
    
    # should over when lucklly.
    bundle exec rake crontab:remove
    bundle exec rake crontab:add
    tail -f log/*
    
    # start up with chkdog
    /bin/sh chkdog.sh
```

### ROUTE

```
  # common page
  /

  # api
  /open/mailer
  /campaign/listener

  # admin page
  /cpanel
  /cpanel/*
```

### FOCUS

  +. all operation under user#webmail 
  +. shell command caculate md5 value - Darwin [md5 -r], Linux [md5sum]

### TODO

  1. start up command with chkonfig when reboot or boot 
  2. bundler/unicorn/rake executed in bash call by crontab will abort "Command NotFound"


### NGINX CONFIGURE

```
    server {
        listen  80;
        server_name wohecha.cn www.wohecha.cn;
        root  /home/work/focus_mail_agent/public;
        passenger_enabled on;
        rails_env development;
        location /static {
          index index.html;
        }
    }
```

### OTHER

````
/public
├── mailgates           for local test
│   ├── log_archive
│   └── mqueue
│       ├── log
│       └── wait
├── mailtem             for server test
│   └── mailtest
├── openapi             for server test
└── pool                for local storage
    ├── archived
    ├── data
    ├── download
    ├── emails
    ├── mailtest
    └── wait
````

### BUG

#### crontab execute base script to startup webserver

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

