require "./config/boot.rb"

map("/")       { run HomeController }
map("/open")   { run OpenController }
map("/server") { run ServerController }
map("/cpanel") { run Cpanel::HomeController }


#run Sinatra::Application
#Rack::Handler::Thin.run @app, :Port => 3000
