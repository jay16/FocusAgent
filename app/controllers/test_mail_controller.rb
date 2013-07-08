#encoding: utf-8
class TestMailController < ApplicationController
    before_filter :chk_unchklog

  def index
    @test_mails = MailTester.order("created_at desc")
  end

  def chk_unchklog
    mails = MailTester.where("log_cm is null or length(log_cm) = 0")
    mails.each do |mail|
      eml_file = mail.eml_file
      eml_name = File.basename(eml_file)
      mq_array = mail.mqpath.split("/")
      mq_array[-1] = "log"
      mq_eth    = mq_array[-2].split("_")
      mq_eth[0] = "mgmailerd"
      log_name  = mq_eth.join("_")+".log"
      log_path  = File.join(mq_array.join("/"),log_name)
      puts "*"*15
      puts log_path
      if File.exist?(log_path) then
         begin
           logs = File.readlines(log_path).grep(/#{eml_name}/)
         rescue => e
           logs = e.backtrace
         end
	 if logs.length then
	   mail.log_cm = logs.join("\n")
	   mail.save
	 end
      else
	puts "ERROR: NOT EXist - #{log_path}"
      end
    end
  end
end
