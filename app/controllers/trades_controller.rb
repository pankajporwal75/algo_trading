class TradesController < ApplicationController
  before_action :get_active_trades, only: [:buy, :sell]
  BASE_URL = 'https://api.dhan.co/v2'
  require 'csv'

  def buy
    if @result[:success]
      @result = fetch_nifty_atm_strike
      if @result[:success]
        symbol = "NIFTY 30 JAN #{@result[:nifty_atm].to_i} CALL"
        security_id = get_security_id(symbol)
        atm_price = get_atm_price(security_id)
        if atm_price[:success]
          quantities = Account.first.capital / atm_price[:price]
          if quantities < 25
            flash[:alert] = 'Capital is not sufficient to buy 1 lots (25 Shares).'
            return
          else
            qty = get_quantities_for_set_capital(atm_price[:price]) # Margin for brokerage
            @result = place_order('BUY', security_id, qty)
            if @result[:success]
              flash[:notice] = 'Buy Order Placed.'
            else
              flash[:alert] = @result[:error]
            end
          end
        else
          flash[:notice] = atm_price[:error]
          return
        end
      else
        flash[:notice] = @result[:error]
        return
      end
    else
      flash[:alert] = @result[:error]
    end
    redirect_to root_path
  end
  
  def sell
    flash[:notice] = 'Sell Order Successfull.'
    redirect_to root_path
  end
  
  def square_off
    flash[:notice] = 'All Positions Squared Off.'
    redirect_to root_path
  end
  
  def reverse
    flash[:notice] = 'Active positions has been reversed.'
    redirect_to root_path
  end

  private

  def get_active_trades
    connection = Faraday.new(
    url: "#{BASE_URL}/positions",
    headers: {
      'Content-Type' => 'application/json',
      'access-token' => Account.first.access_token
    })

    response = connection.get
    body = JSON.parse(response.body, symbolize_names: true)

    @result = if response.success?
      { success: true, positions: body }
    else
      { success: false, error: body[:errorMessage] }
    end
    @result
  end

  def fetch_nifty_atm_strike
    connection = Faraday.new(
      url: "#{BASE_URL}/marketfeed/ltp",
      headers: {
        'Content-Type' => 'application/json',
        'access-token' => Account.first.access_token,
        'client-id' => Account.first.account_id.to_s
    })

    request_body = { "IDX_I": [13] }.to_json

    response = connection.post do |req|
      req.body = request_body
    end

    body = JSON.parse(response.body, symbolize_names: true)
    @result = if response.success?
      nifty_price = body.first[1].first[1].first[1].first[1]
      atm_option = fetch_atm_by_price(nifty_price)
      { success: true, nifty_atm: atm_option }
    else
      { success: false, error: body[:data].first[1] }
    end
  end

  def fetch_atm_by_price(price)
    remainder = price % 50
    if remainder == 0
      atm_price = price
    elsif remainder < 25
      atm_price = price - remainder
    else
      atm_price = price + (50 - remainder)
    end
    atm_price
  end

  def get_security_id(symbol)
    csv_path = Rails.root.join('db', 'data', 'dhan_securities_master.csv')
    CSV.foreach(csv_path, headers: true, header_converters: :symbol) do |row|
      return row[:sem_smst_security_id] if row[:sem_custom_symbol] == symbol
    end
    nil
  end

  def get_atm_price(security_id)
    connection = Faraday.new(
      url: "#{BASE_URL}/marketfeed/ltp",
      headers: {
        'Content-Type' => 'application/json',
        'access-token' => Account.first.access_token,
        'client-id' => Account.first.account_id.to_s
    })

    request_body = { "NSE_FNO": [security_id.to_i] }.to_json

    response = connection.post do |req|
      req.body = request_body
    end

    body = JSON.parse(response.body, symbolize_names: true)
    @result = if response.success?
      price = body.first[1].first[1].first[1].first[1]
      { success: true, price: price }
    else
      { success: false, error: body[:data].first[1] }
    end
  end

  def get_quantities_for_set_capital(price)
    amount = Account.first.capital - 200
    qty = (amount / price).floor
    lots = qty/25
    lots * 25
  end

  def place_order(type, security_id, quantity)
    connection = Faraday.new(
      url: "#{BASE_URL}/orders",
      headers: {
        'Content-Type' => 'application/json',
        'access-token' => Account.first.access_token,
        'client-id' => Account.first.account_id.to_s
    })

    request_body = {
      "dhanClientId": Account.first.account_id.to_s,
      "correlationId": "",
      "transactionType":type,
      "exchangeSegment":"NSE_FNO",
      "productType":"MARGIN",
      "orderType":"MARKET",
      "validity":"DAY",
      "securityId":security_id.to_s,
      "quantity":quantity.to_i,
      "disclosedQuantity":0,
      "price":0,
      "triggerPrice":0,
      "afterMarketOrder":false
    }.to_json

    response = connection.post do |req|
      req.body = request_body
    end

    body = JSON.parse(response.body, symbolize_names: true)
    @result = if response.success?
      { success: true }
    else
      { success: false, error: body[:errorMessage] }
    end
    @result
  end
  
end