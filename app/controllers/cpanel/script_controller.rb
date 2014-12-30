#encoding: utf-8
class Cpanel::ScriptController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/script"
  set :layout, :"../layouts/layout"

  before do
    unless login?
      flash[:warnging] = "please login."
      redirect "/"
    end
  end

  get "/" do
    haml :index, layout: settings.layout
  end

end
