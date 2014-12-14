#encoding: utf-8
class Cpanel::OpenController < Cpanel::ApplicationController

  # params:
  #     timestamp - 20141212
  get "/data" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      now = Time.now
      timestamp = params[:timestamp] || now.strftime("%Y%m%d")
      data_path = File.join(ENV["APP_ROOT_PATH"], Setting.pool.data)
      data_file = File.join(data_path, timestamp) 
      if File.exist?(data_file)
        file_name = now.strftime("%Y%m%d%H%M%S") + ".tar.gz"
        shell = "cd %s && rm %s*.tar.gz" % [data_path, timestamp]
        run_command(shell)
        shell = "cd %s && tar -czvf %s %s" % [data_path, file_name, timestamp]
        run_command(shell)
        file_path = File.join(data_path, file_name)
        send_file(file_path, filename: file_name)
      else
        hash = { code: -1, info: "data file not exist" }
        respond_with_json hash, 200
      end
    end
  end

  # params:
  #     filename: log file name 
  get "/log" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      file_name = params[:filename] || "mgmailerd.log" 
      file_path = File.join(Setting.mailgates.path.log, file_name)
      if File.exist?(file_path)
        send_file(file_path, filename: file_name)
      else
        hash = { code: -1, info: "log file not exist" }
        respond_with_json hash, 200
      end
    end
  end

  # params
  #     timestamp: 20141212
  # /mailgates/log_archive/2014_11/mgmailerd.log.141112.gz 
  get "/archived" do
    if (params[:token] || "token") != Setting.open.token
      hash = { code: 401, info: "token is not correct!" }
      respond_with_json hash, 401
    else
      timestamp = params[:timestamp] || Time.now.strftime("%Y%m%d")
      y_m = timestamp[0..3] + "_" + timestamp[4..5]
      ymd = timestamp[2..-1]
      file_name = ["mgmailerd.log",ymd,"gz"].join(".")
      file_path = File.join(Setting.mailgates.path.archived, y_m, file_name) 
      if File.exist?(file_path)
        send_file(file_path, filename: file_name)
      else
        hash = { code: -1, info: "archived file not exist" }
        respond_with_json hash, 200
      end
    end
  end
end
