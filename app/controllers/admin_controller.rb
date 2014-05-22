#encoding: utf-8
class AdminController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/admin"

  # get /admin
  get "/" do
  end

  # params:
  # token: authenticate! 
  # get /admin/passenger?todo=
  get "/passenger" do
    case params[:todo] || "null"
    when "reload"
        `cd #{ENV["APP_ROOT_PATH"]} && sh passenger.sh restart`
    when "stop"
        `cd #{ENV["APP_ROOT_PATH"]} && sh stop_passenger.sh stop`
    else
      "[stop, reload]"
    end
  end

  # params:
  # email: chk email from /mailgates/mqueue/log/mgmailgates.log
  # return array
  # get /amdin/chklog
  get "/chk_log" do
    if params[:keyword]
        status, *result = run_command("cat #{Settings.mailgates.log_file} | grep -E #{params[:keyword]}")
        @result = ([status] + result).join("<br>")

        haml :code, layout: :"../layouts/layout"
    else
        "please offer params[:keyword]]"
    end
  end

  # [tail mgmailgates.log]
  # return array
  # get /admin/tail_log
  get "/tail_log" do
    status, *result = run_command("tail #{Settings.mailgates.log_file}")
    @result = ([status] + result).join("<br>")

    haml :code, layout: :"../layouts/layout"
  end

  # params:
  # date: yyyymmdd
  # today's log when params[:date] empty?
  get "/download_log" do
    params[:date] ||= Time.now.strftime("%Y%m%d")

    if params[:date] == Time.now.strftime("%Y%m%d")
      log_path = Settings.mailgates.log_file
      send_file(log_path, filename: File.basename(log_path))
    elsif params[:date].to_s.length == 8
      #2014_01
      #mgmailerd.log.140111.gz
      ymd = params[:date][2..-1]
      y_m = params[:date][0..3] + "_" + params[:date][4..5]
      filename = ["mgmailerd.log",ymd,"gz"].join(".")
      log_path = File.join(Settings.mailgates.log_archive_path, y_m, filename)
      File.exist?(log_path) ? send_file(log_path, filename: filename) : ["not exist - ", log_path].join
    else
        "should format:" + Time.now.strftime("%Y%m%d")
    end
  end

  get "/log_archive_tree" do
    path = File.join(Settings.mailgates.log_archive_path, params[:y_m] || "")
    status, *result = run_command("tree #{path}")
    @result = ([status] + result).join("<br>")

    haml :code, layout: :"../layouts/layout"
  end

end
