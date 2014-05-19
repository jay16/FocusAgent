#encoding: utf-8
require "json"
class OpenController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/home"

  #root
  get "/" do
    haml :index, layout: :"../layouts/layout"
  end

  # 接收server呼叫api发信
  # params:
  # format: 文件格式
  # email:  email
  # tar_name: email压缩后文件名
  # strftime
  # md5
  post "/open/mailer" do
    email    = params[:email]
    tar_name = params[:tar_name]
    md5      = params[:md5]
    strftime = params[:strftime]

   if email && tar_name && md5 && strftime
      log_str  = [Time.now.strftime("%Y/%m/%d-%H:%M:%S"), "api", tar_name, md5, email, strftime, remote_ip, remote_browser].join(",")
      log_file = File.join(ENV["APP_ROOT_PATH"],"log","open-api.log")
      wget_file = File.join(ENV["APP_ROOT_PATH"], "public/wget_pool", ["api", Time.now.to_i, md5.strip].join("-") + ".wget")
      ` echo #{log_str} >> #{log_file}`
      ` echo #{log_str} > #{wget_file}`

      hash = { :code => 1, :info => "deliver..." }
    else
      hash = { :code => -1, :info => "less data:#{params.to_s}" }
    end

    content_type :json
    hash.to_json
  end

  #接收server呼叫发送测试信
  # filename: email压缩文件名
  # md5     : email压缩文件md5值
  # sdate   : server date
  # mail_type : 测试类型, 0 为内测， 1为搬信
  get "/campaigns/listener" do
    filename  =  params[:filename]   #campaign_id活动id
    md5       =  params[:md5] 
    mail_type =  params[:mail_type] || "none"

    if filename && md5
      log_str  = [Time.now.strftime("%Y/%m/%d-%H:%M:%S"), "test", filename, md5, mail_type, "blank", remote_ip, remote_browser].join(",")
      log_file = File.join(ENV["APP_ROOT_PATH"],"log","open-api.log")
      wget_file = File.join(ENV["APP_ROOT_PATH"], "public/wget_pool", ["test", Time.now.to_i, md5.strip].join("-") + ".wget")
      ` echo #{log_str} >> #{log_file}`
      ` echo #{log_str} > #{wget_file}`

      hash = { :code => 1, :info => "deliver..." }
    else
      hash = { :code => -1, :info => "less data:#{params.to_s}" }
    end

    content_type :json
    hash.to_json
  end
end
