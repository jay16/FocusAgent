#encoding: utf-8
#验证名单
class ChkMailController < ApplicationController
  def index
    root_dir = "/home/webmail/focus_agent"
    chk_eml  = File.join(root_dir,"chk_eml")
    @tasks    = Array.new
    Dir.foreach(chk_eml) do |dir|
      next if dir == "." or dir == ".."
      current = File.join(chk_eml,dir)
      @tasks.push(current) if File.directory?(current)
    end
    
  end

  def check
  end

  def edit
  end
end
