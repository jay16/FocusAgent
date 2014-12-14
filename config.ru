require "./config/boot.rb"

map("/")            { run HomeController }
map("/cpanel")      { run Cpanel::HomeController }
map("/cpanel/open") { run Cpanel::OpenController }


#run Sinatra::Application
#Rack::Handler::Thin.run @app, :Port => 3000
