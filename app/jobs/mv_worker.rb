class MV_Worker
  @queue = "MV_Worker"

  def self.perform(domain)
    domain.downcase!
    domains = %w(qq 126 sina sohu yahoo tom gmail hotmail other)
    if(domains.include?(domain))
      FocusAgent::SendMail.fork(domain)
    else
     raise "#{domain} not in #{domains.to_s}" 
    end

  end
end


class MV_Sohu
  @queue = "MV_Sohu"

  def self.perform()
     MV_Worker.perform("sohu")
  end
end

class MV_QQ
  @queue = "MV_QQ"

  def self.perform()
     MV_Worker.perform("qq")
  end
end
