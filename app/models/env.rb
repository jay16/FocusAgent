class Env < ActiveRecord::Base
  attr_accessible :gem, :idstr, :iptables, :issue, :online, :pid, :port, :rails, :ruby, :selinux, :time_zone, :used, :user, :volume

#idstr:对本机的标识 issue:系统版本
#pid:启动分配的进程ip port:启动端口 time_zone:本地时区 
#user:启运用户名 volume:启用用户分配空间 used:使用掉的空间
#rails:rails版本 ruby:ruby版本 gem:gem版本 
#selinux:selinux是否启动 iptables:防火墙设置
#online:网络是否可通
end
