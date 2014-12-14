#encoding: utf-8
class Cpanel::HomeController < Cpanel::ApplicationController
  set :views, ENV["VIEW_PATH"] + "/cpanel/home"
  set :layout, :"../../layouts/layout"

  before do
  end

  get "/" do
    haml :index, layout: settings.layout
  end
end
