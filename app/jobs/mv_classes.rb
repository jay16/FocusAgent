class MV_QQ
  @queue = "QQ_Mover"

  def self.perform
    FocusAgent::SendMail.fork('qq')
  end
end

class MV_Sohu
  @queue = "Sohu_Mover"

  def self.perform
    FocusAgent::SendMail.fork('sohu')
  end
end

class MV_Other
  @queue = "Other_Mover"

  def self.perform
    FocusAgent::SendMail.fork('other')
  end
end
