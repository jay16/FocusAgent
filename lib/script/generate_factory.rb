hash = eval(IO.readlines("./log/alipay.log.txt")[0])
hash.each_pair do |k, v|
  puts %Q(#{k} - #{v})
  puts %Q(sequence(:#{k}) { |n| \"#{k}_\#{n}\" })
end
