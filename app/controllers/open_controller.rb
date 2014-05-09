#encoding: utf-8
class OpenController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/home"

  #root
  get "/" do
    haml :index, layout: :"../layouts/layout"
  end

  #接收server呼叫api发信
  # params:
  # format: 文件格式
  # email:  email
  # tar_name: email压缩后文件名
  # strftime
  # md5
  post "/open/mailer" do
  end

  #接收server呼叫发送测试信
  # filename: email压缩文件名
  # md5     : email压缩文件md5值
  # sdate   : server date
  # mail_type : 测试类型, 0 为内测， 1为搬信
  get "/campaigns/listener" do
  end
end
