
ii ="1893-520936_1372495704.5822256.eml"

rt = File.readlines("/webmail/mqueue_qq_eth3/log/mgmailerd_qq_eth3.log").grep(/#{ii}/)

puts rt.to_s
