def popen(cmd)
  IO.popen(cmd) do |stdout|
    stdout.reject(&:empty?)
  end.unshift($?.exitstatus.zero?)
end

["ps -p #{Process.pid} -o %cpu,%mem"].each do |cmd|
  status, *result = popen(cmd)
  puts result.map(&:split).transpose.join(",")
end

#public_path = File.expand_path("../../../public", __FILE__)
#Dir.entries(public_path).each do |i|
#  puts i
#end
