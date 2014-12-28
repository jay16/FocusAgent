#encoding: utf-8
class UserController < ApplicationController
  set :views, ENV["VIEW_PATH"] + "/user"
  set :layout, :"../layouts/layout"

  # GET /cpanel/login
  get "/login" do
    haml :login, layout: settings.layout
  end

  # POST /cpanel/login
  post "/login" do
    token = params[:token] || "unset"
    if md5_key(token) == md5_key(Setting.open.token)
      response.set_cookie "token", {:value=> md5_key(token), :path => "/", :max_age => "2592000"}

      flash[:success] = "登陆成功"
      redirect "/cpanel"
    else
      response.set_cookie "token", {:value=> "", :path => "/", :max_age => "2592000"}

      flash[:warning] = "Token不正确, %s" % Setting.open.token
      redirect "/user/login"
    end
  end

  # delete /user/logout
  get "/logout" do
    response.set_cookie "token", {:value=> "", :path => "/", :max_age => "2592000"}
    redirect "/"
  end
end
