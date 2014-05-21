#encoding: utf-8
class AdminController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/admin"

  # get /admin
  get "/" do
  end

  # params:
  # token: authenticate! 
  # get /admin/reload_passenger
  get "/reload_passenger" do
    `cd #{ENV["APP_ROOT_PATH"]} && sh reload_passenger.sh`
  end

  # params:
  # email: chk email from /mailgates/mqueue/log/mgmailgates.log
  # return array
  # get /amdin/chklog
  get "/chklog" do
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
  get "/log_file" do
  end

end
