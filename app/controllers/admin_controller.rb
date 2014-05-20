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
  end

  # params:
  # date: yyyymmdd
  # today's log when params[:date] empty?
  get "/log_file" do
  end

end
