## [FocusMailAgent]

### COMMAND

```
    # web server
    bundle install
    sh unicorn.sh {start|stop|restart}

    # crontab
    sh crontab.sh

    # test with RSpec
    bundle exec rspec spec/controller/

    # assets generator
    bundle exec rake cs2js:complie

    # rake tasks
    bundle exec rake agent:deploy
    bundle exec rake agent:clear
    bundle exec rake agent:main
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
  /cpanel/open
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
