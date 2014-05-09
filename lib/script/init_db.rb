#encoding: utf-8
require "nokogiri"
require "net/http"
require "uri"

url  = "http://127.0.0.1"
port = 3000
base_url = [url, port].join(":")
lines = IO.readlines(File.expand_path("./../../log/alipay.log.txt", File.dirname(__FILE__)))

def base_test_post base_url, path, params
  uri = URI.parse(File.join(base_url, path))
  res = Net::HTTP.post_form(uri, params) 

  puts "=" * 10
  puts ["post", uri.to_s].join(" ")
  puts "测试结果:"
  puts res.code
  puts res.message
end

def base_test_get base_url, path, chk_str, params = {}
  uri = URI.parse(File.join(base_url, path))
  uri.query = URI.encode_www_form(params) if !params.empty?
  res = Net::HTTP.get(uri) #, {"accept-encoding" => "UTF-8"})

  puts "=" * 10
  puts ["get", uri.to_s].join(" ")
  puts "测试结果:"
  puts "界面正常显示:" + (res.is_a?(Net::HTTPSuccess) ? res.body : res).force_encoding("UTF-8").include?(chk_str).to_s
end


  
lines.each do |line|
  params = eval(line)
  puts params
  
  # 测试root
  # get "/"
  subject = "支付宝{双功能接口}示范程序" # 返回内容是否包含标题
  base_test_get base_url, "/", subject
  
  # 测试提交
  # post /checkout
  base_test_post base_url, "checkout", params
  
  # 测试transactions/notify
  # post "/transactions/notify"
  base_test_post base_url, "transactions/notify", params
  
  # 测试 transations/done
  # get "/transactions/done"
  chk_str = %Q([:notice, "done"])
  base_test_get base_url, "/transactions/done", chk_str, params
end

