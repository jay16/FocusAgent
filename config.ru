require "./config/boot.rb"

map("/") { run OpenController }


#run Sinatra::Application
#Rack::Handler::Thin.run @app, :Port => 3000
