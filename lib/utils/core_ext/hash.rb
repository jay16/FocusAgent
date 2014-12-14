module HashMethods
  def self.included(base)
    base.extend(self)
  end
  def perfect!
    keys.each do |key|
      value = values_at(key).first
      case key
      when String
        self[key.to_sym] = value
      when Symbol
        self[key.to_s] = value
      else
        puts "[warn] %s is_a %s" % [key.to_s, key.class]
      end
    end
    self
  end
end
class Hash
  include HashMethods
end
