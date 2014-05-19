#encoding: utf-8
require "nokogiri"
require "net/http"
require "uri"

url  = "http://127.0.0.1"
port = 3456
base_url = [url, port].join(":")

def base_test_post base_url, path, params
  uri = URI.parse(File.join(base_url, path))
  res = Net::HTTP.post_form(uri, params) 

  puts "=" * 10
  puts ["post", uri.to_s].join(" ")
  puts "测试结果:"
  puts res.code
  puts res.message
  puts (res.is_a?(Net::HTTPSuccess) ? res.body : res).force_encoding("UTF-8")
end

def base_test_get base_url, path, params = {}
  uri = URI.parse(File.join(base_url, path))
  uri.query = URI.encode_www_form(params) if !params.empty?
  res = Net::HTTP.get(uri) #, {"accept-encoding" => "UTF-8"})

  puts "=" * 10
  puts ["get", uri.to_s].join(" ")
  puts "测试结果:"
  puts "界面正常显示:" + (res.is_a?(Net::HTTPSuccess) ? res.body : res).force_encoding("UTF-8")
end

params = eval(%Q({"email"=>"327264757@qq.com", "tar_name"=>"327264757-qq.com_20140510225710.eml.tar.gz", "strftime"=>"2014-05-10 22:57:10", "md5"=>"347e5dad0bd0f12c168b885a3ddcf250", "open"=>{"format"=>"json", "email"=>"327264757@qq.com", "tar_name"=>"327264757-qq.com_20140510225710.eml.tar.gz", "strftime"=>"2014-05-10 22:57:10", "md5"=>"347e5dad0bd0f12c168b885a3ddcf250", "controller"=>"open", "action"=>"mailer"}}))
base_test_post(base_url, "open/mailer", params)
params = eval(%Q({"format"=>"json", "email"=>"327264757@qq.com", "filename"=>"327264757-qq.com_20140510225710.eml.tar.gz", "strftime"=>"2014-05-10 22:57:10", "md5"=>"347e5dad0bd0f12c168b885a3ddcf250", "controller"=>"open", "action"=>"mailer"}))
base_test_get(base_url, "campaigns/listener", params)
#puts params
