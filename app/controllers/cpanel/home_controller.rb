#encoding: utf-8
class Cpanel::HomeController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/home"
  set :layout, :"../layouts/layout"

  before do
    unless login?
      flash[:warnging] = "please login."
      redirect "/"
    end
  end

  get "/" do
    command = "cd %s && du -sh ./" % ENV["APP_ROOT_PATH"]
    @app_size = run_command(command).last.split.first
    @app_size << " / "
    command = "cd %s && du -sh public" % ENV["APP_ROOT_PATH"]
    @app_size << run_command(command).last.split.first

    @whoami = run_command("whoami").last.split.first

    haml :index, layout: settings.layout
  end

  get "/doc" do
    haml :doc, layout: settings.layout
  end
end
