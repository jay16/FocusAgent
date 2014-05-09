FactoryGirl.define do
  factory :transaction do
      gmt_send_goods Time.now.strftime("%Y-%m-%d %H:%M:%S") 
      discount "0"
      logistics_type "DIRECT"
      sequence(:receive_zip) { |n| "20121#{n}" }
      payment_type "1"
      sequence(:subject) { |n| "subject_#{n}" }
      logistics_fee "0"
      trade_no Time.now.to_i.to_s 
      sequence(:buyer_email) { |n| "buyer_email_#{n}" }
      sequence(:gmt_create) { |n| "gmt_create_#{n}" }
      sequence(:notify_type) { |n| "notify_type_#{n}" }
      sequence(:quantity) { |n| "quantity_#{n}" }
      sequence(:logistics_payment) { |n| "logistics_payment_#{n}" }
      sequence(:out_trade_no) { |n| "out_trade_no_#{n}" }
      sequence(:seller_id) { |n| "seller_id_#{n}" }
      sequence(:notify_time) { |n| "notify_time_#{n}" }
      trade_status "TRADE_FINISHED"
      sequence(:is_total_fee_adjust) { |n| "is_total_fee_adjust_#{n}" }
      sequence(:gmt_payment) { |n| "gmt_payment_#{n}" }
      sequence(:total_fee) { |n| "total_fee_#{n}" }
      sequence(:seller_email) { |n| "seller_email_#{n}" }
      sequence(:gmt_close) { |n| "gmt_close_#{n}" }
      sequence(:price) { |n| "price_#{n}" }
      sequence(:buyer_id) { |n| "buyer_id_#{n}" }
      sequence(:receive_mobile) { |n| "receive_mobile_#{n}" }
      sequence(:gmt_logistics_modify) { |n| "gmt_logistics_modify_#{n}" }
      sequence(:notify_id) { |n| "notify_id_#{n}" }
      sequence(:receive_name) { |n| "receive_name_#{n}" }
      sequence(:use_coupon) { |n| "use_coupon_#{n}" }
      sequence(:sign_type) { |n| "sign_type_#{n}" }
      sequence(:sign) { |n| "sign_#{n}" }
      sequence(:receive_address) { |n| "receive_address_#{n}" }
  end
end
