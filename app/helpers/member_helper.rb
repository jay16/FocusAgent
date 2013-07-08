module MemberHelper
  
  def cal_result(eml_dir)
    write_report(eml_dir) unless read_report(eml_dir)
  end
  
  #若已存在计算验证名单报告文件，直接读取
  def read_report(eml_dir)
    all_files = Dir.entries(eml_dir)
    rt_files   = all_files.grep(/_FocusAgent_ChkResult.csv&/)
    
    report = Array.new
    if rt_files.length >=1 then
      rt_file = File.join(eml_dir,rt_file[0])
      lines = File.readlines(rt_file)
      lines.each do |line|
        report.push(line.split(","))
      end
      puts "*"*50
      puts "NOT CAL AGAIN!"
      return report
    else
      return false
    end
  end
  
  #汇总验证数据，并写入默认文件名称中
  def write_report(eml_dir)
    report = Array.new
    all_rows, all_valids = 0, 0
    Dir.entries(eml_dir).grep(/.*_result.csv$/).each do |file|
      file_dir = File.join(eml_dir,file)
      f = File.readlines(file_dir)
      f.uniq!
  
      begin #文本中可能会含非UTF-8编码内容
        rows   =  f.grep(/@/).length
        valids =  f.grep(/,(1|4|5)/).length
      rescue => e
        #check every line
        f.each_with_index do |line, index|
          begin
           rows   += 1 if line.scan(/@/)          #只匹配含@的行
           valids += 1 if line.scan(/,(1|4|5|)/)  #验证名单结果格式:email,1  匹配1/4/5
          rescue => se
           puts se.message
           puts %Q{index: #{index} line: #{line}}
          end
        end
      end
  
      report.push([rows, valids, file])
      all_rows   += rows
      all_valids += valids
    end
    report.push([all_rows, all_valids, "sum_all"])
    
    File.open("#{eml_dir}/#{File.basename(eml_dir)}_FocusAgent_ChkResult.csv","w+") do |file|
      report.each do |rt|
        file.puts(rt.join(","))
      end
    end
    
    return report
  end
    
end
