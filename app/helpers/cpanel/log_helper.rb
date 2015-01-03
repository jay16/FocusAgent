# encoding: utf-8
module CpanelLogHelper
  def simple_result(str)
    retry_regexp = /^RETRY\.(\d+)/
    if str =~ retry_regexp 
      "R.%d" % str.scan(retry_regexp)[0][0]
    elsif str =~ /^FAIL/
      "F"
    elsif str =~ /^OK/
      "OK"
    else
      str[0..4]
    end
  end
end
