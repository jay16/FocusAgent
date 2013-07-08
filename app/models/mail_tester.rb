class MailTester < ActiveRecord::Base
  attr_accessible :campaign_id, :domain, :email, :eml_file, :log_cm, :mqpath
end
