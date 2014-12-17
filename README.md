## [FocusMailAgent]


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

### MENTTION

  1. shell command caculate md5 value - Darwin [md5 -r], Linux [md5sum]
  2. application and rake should execute with [webmail:webmail]
  3. all operation under webmail user

### TODO



### COMMAND

```
    # web server
    bundle install
    sh lib/script/unicorn.sh {start|stop|restart}

    # crontab
    sh lib/script/crontab.sh

    # test with RSpec
    bundle exec rspec spec/controller/

    # assets generator
    bundle exec rake cs2js:complie

    # rake tasks
    bundle exec rake agent:deploy
    bundle exec rake agent:clear
    bundle exec rake agent:main
```

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
