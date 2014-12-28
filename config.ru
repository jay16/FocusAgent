require "./config/boot.rb"

map("/")            { run HomeController }
map("/user")        { run UserController }
map("/cpanel")      { run Cpanel::HomeController }
map("/cpanel/data") { run Cpanel::DataController }
map("/cpanel/log")  { run Cpanel::LogController }
map("/cpanel/open") { run Cpanel::OpenController }


#run Sinatra::Application
#Rack::Handler::Thin.run @app, :Port => 3000
