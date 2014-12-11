#encoding: utf-8
class OpenController < ApplicationController

  # 接收server呼叫api发信
  # params:
  #   format: 文件格式
  #   email:  email
  #   tar_name: email压缩后文件名
  #   strftime
  #   md5
  get "/mailer" do
    open_mailer_action
  end

  post "/mailer" do
    open_mailer_action
  end

  #接收server呼叫发送测试信
  # filename: email压缩文件名
  # md5     : email压缩文件md5值
  # sdate   : server date
  # mail_type : 测试类型, 0 为内测， 1为搬信
  get "/campaigns/listener.json" do
    campaigns_listener_action
  end

  post "/campaigns/listener.json" do
    campaigns_listener_action
  end

  def open_mailer_action
    email    = params[:email]
    tar_name = params[:tar_name]
    md5      = params[:md5]
    strftime = params[:strftime]

    if email && tar_name && md5 && strftime
      log_str  = [Time.now.strftime("%Y/%m/%d-%H:%M:%S"), "api", tar_name, md5, email, strftime, remote_ip, remote_browser].join(",")
      log_file = File.join(ENV["APP_ROOT_PATH"],"log","open-api.log")
      wget_file = "%s/%s/%s" % [ENV["APP_ROOT_PATH"], Setting.pool.wait, ["api", Time.now.to_f.to_s].join("-") + ".wget"]

      shell = %Q{echo "%s" >> %s} % [log_str, log_file]
      puts run_command(shell)
      shell = %Q{echo "%s" >> %s} % [log_str, wget_file]
      puts run_command(shell)

      hash = { :code => 1, :info => "deliver..." }
    else
      hash = { :code => -1, :info => "less data:#{params.to_s}" }
    end

    content_type :json
    hash.to_json
  end


  def campaigns_listener_action
    filename  =  params[:filename]   
    md5       =  params[:md5] 
    mail_type =  params[:mail_type] || "none"

    if filename && md5
      log_str   = [Time.now.strftime("%Y/%m/%d-%H:%M:%S"), "test", filename, md5, mail_type, "blank", remote_ip, remote_browser].join(",")
      log_file  = File.join(ENV["APP_ROOT_PATH"],"log","open-api.log")
      wget_file = File.join(ENV["APP_ROOT_PATH"], "public/pool/wait", ["test", Time.now.to_f.to_s].join("-") + ".wget")

      shell = %Q{echo "%s" >> %s} % [log_str, log_file]
      puts run_command(shell)
      shell = %Q{echo "%s" >> %s} % [log_str, wget_file]
      puts run_command(shell)

      hash = { :code => 1, :info => "deliver..." }
    else
      hash = { :code => -1, :info => "less data:#{params.to_s}" }
    end

    content_type :json
    hash.to_json
  end
end
