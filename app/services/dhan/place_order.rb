class Dhan::PlaceOrder
  def self.call(order_type, security_id, quantity)
    new(order_type, security_id, quantity).process
  end

  attr_reader :order_type, :security_id, :quantity
  def initialize(order_type, security_id, quantity)
    @order_type = order_type
    @security_id = security_id
    @quantity = quantity
  end

  def process
    connection = Faraday.new(
      url: "#{ENV['DHAN_API_URL']}/orders",
      headers: {
        'Content-Type' => 'application/json',
        'access-token' => ENV['DHAN_API_KEY'],
        'client-id' => ENV['DHAN_CLIENT_ID'].to_s
    })

    request_body = order_params.to_json

    response = connection.post do |req|
      req.body = request_body
    end

    body = JSON.parse(response.body, symbolize_names: true)
    @result = if response.success?
      { success: true }
    else
      { success: false, error: body[:errorMessage] }
    end
  end

  private

  def order_params
    {
      "dhanClientId": ENV['DHAN_CLIENT_ID'].to_s,
      "correlationId": "",
      "transactionType":order_type,
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
    }
  end
end