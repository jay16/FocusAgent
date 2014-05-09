class Settings < Settingslogic
    source "config/settings.yaml"
    namespace  ENV["RACK_ENV"] 
end
