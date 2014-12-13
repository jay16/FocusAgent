## [FocusMailAgent]


### ROUTE

```
  # common page
  /         

  # administrator page
  /cpanel
```

### MENTTION

  1. shell command get md5 value - Darwin [md5 -r], Linux [md5sum]
  2. user and group should [webmail:webmail]

### TODO

  [ ]. switch shell command [md5]
  [ ]. action record data
  [ ]. api for record data
  [ ]. page design

### COMMAND

```
    # start up
    bundle install
    bundle exec thin start

    # test with RSpec
    bundle exec rspec spec/controller/

    # assets generator
    bundle exec rake cs2js:complie

    # rake tasks
    bundle exec rake agent:deploy
    bundle exec rake agent:clear
    bundle exec rake agent:main
```

### nginx configure

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
