#encoding: utf-8
require File.expand_path '../../spec_helper.rb', __FILE__

describe "TransactionsController" do
  def response; last_response; end
  def request;  last_request;  end
  def flash; request.env["rack.session"]["flash"]; end
  def options; request.env["rack.session.options"]; end

  let(:valid_param) { { "trade_status" => "TRADE_FINISHED", "out_trade_no" => Time.now.to_i.to_s } }

  # post "/checkout", { 金额、数量、折扣 }
  # 跳转至alipay官方网站付账界面
  it "should redirect to alipay page when checkout" do
    post "/transactions/checkout", { :amount => rand(100),  :order => "order list" }

    expect(response.status).to eq(302) # 跳转页面
  end

  # post "/transactions/notify"
  # 创建Transaction
  # 显示text: "success"
  it "should create transaction when alipay over" do
    expect { post "/transactions/notify", valid_param }.to change(Transaction, :count).by(1)

    expect(response).to be_ok
    expect(response.body.strip).to eq("success")
  end

  # get /trnasctions/done
  it "should render text '付款成功啦'" do
    get "/transactions/done?buyer_email=jay_li%40solife.us&buyer_id=2088802087947025&discount=0.00&gmt_create=2014-05-05+20%3A28%3A18&gmt_logistics_modify=2014-05-05+20%3A28%3A31&gmt_payment=2014-05-05+20%3A29%3A22&is_success=T&is_total_fee_adjust=N&logistics_fee=0.00&logistics_payment=SELLER_PAY&logistics_type=DIRECT&notify_id=RqPnCoPT3K9%252Fvwbh3I74lyMi0wj7wIWODjOm2P7f%252FIHlHnq%252F8pf1iJKWRVYgcAdCpPh7&notify_time=2014-05-05+20%3A29%3A26&notify_type=trade_status_sync&out_trade_no=1399292863&payment_type=1&price=0.01&quantity=1&receive_address=%E4%B8%8A%E6%B5%B7+%E4%B8%8A%E6%B5%B7%E5%B8%82+%E9%9D%99%E5%AE%89%E5%8C%BA+%E4%B8%8A%E6%B5%B7%E5%B8%82%E9%9D%99%E5%AE%89%E5%8C%BA%E6%B1%9F%E5%AE%81%E8%B7%AF167%E5%8F%B7%E6%96%B0%E5%9F%8E%E5%A4%A7%E5%8E%A6703%E5%AE%A4+200041&receive_mobile=13564379606&receive_name=%E6%9D%8E%E4%BF%8A%E6%9D%B0&receive_zip=200041&seller_actions=SEND_GOODS&seller_email=wan%40xiaojiti.com&seller_id=2088212078009126&subject=%E6%88%91%E5%96%9D%E8%8C%B6%E8%AE%A2%E5%8D%95+-+%EF%BF%A50.01&total_fee=0.01&trade_no=2014050535799302&trade_status=WAIT_SELLER_SEND_GOODS&use_coupon=N&sign=dc69ae5fd986596c5ded94af68875067&sign_type=MD5%20HTTP/1.1%20HTTP/1.1%20HTTP/1.1%22%20404%205%200.0636%20127.0.0.1%20-%20-%20[06/May/2014%2022:55:43]%20%22GET%20/transactions/done?buyer_email=jay_li%40solife.us&buyer_id=2088802087947025&discount=0.00&gmt_create=2014-05-05+20%3A28%3A18&gmt_logistics_modify=2014-05-05+20%3A28%3A31&gmt_payment=2014-05-05+20%3A29%3A22&is_success=T&is_total_fee_adjust=N&logistics_fee=0.00&logistics_payment=SELLER_PAY&logistics_type=DIRECT&notify_id=RqPnCoPT3K9%252Fvwbh3I74lyMi0wj7wIWODjOm2P7f%252FIHlHnq%252F8pf1iJKWRVYgcAdCpPh7&notify_time=2014-05-05+20%3A29%3A26&notify_type=trade_status_sync&out_trade_no=1399292863&payment_type=1&price=0.01&quantity=1&receive_address=%E4%B8%8A%E6%B5%B7+%E4%B8%8A%E6%B5%B7%E5%B8%82+%E9%9D%99%E5%AE%89%E5%8C%BA+%E4%B8%8A%E6%B5%B7%E5%B8%82%E9%9D%99%E5%AE%89%E5%8C%BA%E6%B1%9F%E5%AE%81%E8%B7%AF167%E5%8F%B7%E6%96%B0%E5%9F%8E%E5%A4%A7%E5%8E%A6703%E5%AE%A4+200041&receive_mobile=13564379606&receive_name=%E6%9D%8E%E4%BF%8A%E6%9D%B0&receive_zip=200041&seller_actions=SEND_GOODS&seller_email=wan%40xiaojiti.com&seller_id=2088212078009126&subject=%E6%88%91%E5%96%9D%E8%8C%B6%E8%AE%A2%E5%8D%95+-+%EF%BF%A50.01&total_fee=0.01&trade_no=2014050535799302&trade_status=WAIT_SELLER_SEND_GOODS&use_coupon=N&sign=dc69ae5fd986596c5ded94af68875067&sign_type=MD5%20HTTP/1.1%20HTTP/1.1%20HTTP/1.1"

    expect(response).to be_ok
    expect(response.body.strip).to include("交易完成")
  end

  # get /transaction/:out_trade_no
  # 根据out_trade_no查找Transaction
  # 需要登陆
  it "should return the transction with out_trade_no" do
    visit "/admin/login"
    fill_in "name",     :with => SiteConfig.login.name
    fill_in "password", :with => SiteConfig.login.password
    click_button "登陆"
    page.should have_content("Signed in successfully.")
    #request.session[:login_state] = true

    #transaction = FactoryGirl.create(:transaction)
    #get "/transactions/#{transaction.out_trade_no}"

    #expect(response).to be_ok
    #expect(response.status).to eq(200)
    #expect(response.body).to include(transaction.out_trade_no)
  end
end

