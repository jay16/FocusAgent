require 'resque/server'

FocusAgent::Application.routes.draw do
   root :to => 'agent#index'
   
   match ':controller(/:action(/:id))(.:format)'
   
   mount Resque::Server.new, :at => '/resque'
end
