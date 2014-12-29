#encoding: utf-8
#require "lib/utils/crontab_robot.rb"
class Cpanel::ScriptController < Cpanel::ApplicationController
  #register Sinatra::CrontabRobot
  #configure do
  #  set :tmp_path, File.join(ENV["APP_ROOT_PATH"], "tmp") 
  #end
  set :views, ENV["VIEW_PATH"] + "/cpanel/script"
  set :layout, :"../layouts/layout"

  before do
    unless login?
      flash[:warnging] = "please login."
      redirect "/"
    end
  end

  get "/" do
    @jobs = crontab_list
    haml :index, layout: settings.layout
  end

end
