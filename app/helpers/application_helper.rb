module ApplicationHelper

  def notice_message
     #close = link_to("x", "#", { :class => "close", "data-dismiss" => "alert" })
     tag(:div, flash[:notice], { :class => "alert alert-success" }) if flash[:notice]
  end
end
