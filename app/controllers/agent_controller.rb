#encoding: utf-8
#agent main controller
class AgentController < ApplicationController
  def index
  end
  
  #操作mqueue路径
  def mqueues
    @mqueues = Mqueue.all
  end
  
  def chk_log
    FocusAgent::MailTest.chkLOG
    @mails = MailTester.order("created_at desc")
  end
  
  def chk_mg
    mg_root = "/webmail"
    mqueues = Array.new
    Dir.foreach(mg_root) do |dir|
      if dir =~ /mqueue/
        mq_path = File.join(mg_root,dir)
        puts "*"*10
        puts mq_path
        mqueues.push(mq_path) 
        if Mqueue.where("mqpath = '#{mq_path}'").count == 0
          Mqueue.create({
            :mqpath   => mq_path,
            :is_valid => true
             }).save
        end
      end
    end
    render :text => mqueues.to_s
  end
  def flux
  end

  def tasks
  end
end
