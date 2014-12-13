#encoding: utf-8
class HomeController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/home"
  set :layout, :"../layouts/layout"

  #root
  get "/" do
    haml :index, layout: settings.layout
  end

  get "/admin" do
    redirect "/cpanel"
  end

  # test api as server
  # download tar file from public/openapi/
  get "/public/openapi/:file", "/openapi/:file" do
    file_name = params[:file]
    file_path = "%s/public/openapi/%s" % [ENV["APP_ROOT_PATH"], file_name]
    send_file(file_path, :filename => file_name)
  end

  # test api as server
  # download tar file from /mailitem/mailtest/:filename
  get "/mailtem/mailtest/:file" do
    file_name = params[:file]
    file_path = "%s/public/mailtem/mailtest/%s" % [ENV["APP_ROOT_PATH"], file_name]
    send_file(file_path, :filename => file_name)
  end

  #
  #  api respondse
  #
  # ����server����api����
  # params:
  #   format: �ļ���ʽ
  #   email:  email
  #   tar_name: emailѹ�����ļ���
  #   strftime
  #   md5
  route :get, :post, "/open/mailer" do
    email    = params[:email]
    tar_name = params[:tar_name]
    md5      = params[:md5]
    strftime = params[:strftime]

    if email && tar_name && md5 && strftime
      log_str  = [Time.now.strftime("%Y/%m/%d-%H:%M:%S"), "api", tar_name, md5, email, strftime, remote_ip, remote_browser].join(",")
      log_file = File.join(ENV["APP_ROOT_PATH"],"log","open-api.log")
      csv_file = "%s/%s/%s" % [ENV["APP_ROOT_PATH"], Setting.pool.wait, ["api", Time.now.to_f.to_s].join("-") + ".csv"]

      shell = %Q{echo "%s" >> %s} % [log_str, log_file]
      puts run_command(shell)
      shell = %Q{echo "%s" >> %s} % [log_str, csv_file]
      puts run_command(shell)

      hash = { :code => 1, :info => "deliver..." }
    else
      hash = { :code => -1, :info => "less data:#{params.to_s}" }
    end
    respond_with_json hash, 200
  end

  #����server���з��Ͳ�����
  # filename: emailѹ���ļ���
  # md5     : emailѹ���ļ�md5ֵ
  # sdate   : server date
  # mail_type : ��������, 0 Ϊ�ڲ⣬ 1Ϊ����
  route :get, :post, "/campaigns/listener.json" do
    filename  =  params[:filename]   
    md5       =  params[:md5] 
    #sdate     =  params[:sdate]
    mail_type =  params[:mail_type] || "none"

    if filename && md5
      log_str   = [Time.now.strftime("%Y/%m/%d-%H:%M:%S"), "test", filename, md5, mail_type, "blank", remote_ip, remote_browser].join(",")
      log_file  = File.join(ENV["APP_ROOT_PATH"],"log","open-api.log")
      csv_file = File.join(ENV["APP_ROOT_PATH"], "public/pool/wait", ["test", Time.now.to_f.to_s].join("-") + ".csv")

      shell = %Q{echo "%s" >> %s} % [log_str, log_file]
      puts run_command(shell)
      shell = %Q{echo "%s" >> %s} % [log_str, csv_file]
      puts run_command(shell)

      hash = { :code => 1, :info => "deliver..." }
    else
      hash = { :code => -1, :info => "less data:#{params.to_s}" }
    end

    respond_with_json hash, 200
  end
end
