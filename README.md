## [我喝茶](http://wohecha.cn/)


### ROUTE

```
  #普通界面
  /         # 首页
  /home     # home
  /cart     # 购物车

  #alipay支付
  /transactions/done
  /transactions/notify
  /transactions/checkout

  #管理界面
  /admin
```

### USAGE

```
# start up
bundle install
thin start

# test with RSpec
rspec spec/controller/transactions_controller_spec.rb

# when add new coffeescript in assets/coffeescripts
# rake this task then generate js file in assets/javascripts 
bundle exec rake coffee2js:complie
```

### nginx configure

```
    server {
        listen  80;
        server_name wohecha.cn www.wohecha.cn;
        root  /home/work/wohecha_with_sinatra/public;
        passenger_enabled on;
        rails_env development;
        location /static {
          index index.html;
        }
    }
```



### Code Statistics

``` 
rake stats
+----------------------+-------+-------+---------+---------+-----+-------+
| Name                 | Lines | LOC   | Classes | Methods | M/C | LOC/M |
+----------------------+-------+-------+---------+---------+-----+-------+
| Libraries            |    62 |    40 |       0 |       2 |   0 |    18 |
| app/controllers      |    89 |    57 |       2 |       1 |   0 |    55 |
| app/helpers          |     9 |     7 |       0 |       1 |   0 |     5 |
| app/models           |    43 |    42 |       2 |       0 |   0 |     0 |
| test/functional      |    52 |    32 |       1 |       9 |   9 |     1 |
| spec/controller      |    59 |    35 |       0 |       9 |   0 |     1 |
| spec/factories       |    36 |    36 |       0 |       0 |   0 |     0 |
+----------------------+-------+-------+---------+---------+-----+-------+
 Code LOC: 146  Test LOC: 103  Code to Test Ratio: 1:0.7
```
