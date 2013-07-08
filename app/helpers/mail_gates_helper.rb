module MailGatesHelper
  def getMqueueWaitStatus
     mqueue_path = "/webmail"
     mqueue_wait_status = {}
    %w(163 126 sina qq).each do |eth|
      eth_hash = {}
        (0..15).each do |port|
        wait_path = File.join(mqueue_path,"mqueue_#{eth}_eth#{port}","wait")
        mails = Dir.entries(wait_path).grep(/.eml/)
        eth_hash[port]= mails.size
      end
      mqueue_wait_status[eth] = eth_hash
    end 
    mqueue_wait_status
  end
end
