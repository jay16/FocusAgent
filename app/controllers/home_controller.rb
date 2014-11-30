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

  get "/public/openapi/:tar_file" do
    file_name = params[:tar_file]
    file_path = "%s/public/openapi/%s" % [ENV["APP_ROOT_PATH"], file_name]
    send_file(file_path, :filename => file_name)
  end

end
