class Setting < Settingslogic
    source "config/setting.yaml"
    namespace  ENV["RACK_ENV"] 
end
