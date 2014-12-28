#encoding: utf-8
class Cpanel::DataController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/data"
  set :layout, :"../layouts/layout"

  get "/" do
    haml :index, layout: settings.layout
  end

end
