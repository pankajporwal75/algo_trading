class Dhan::GetPriceQuote
  def self.call(security_type, security_id)
    new(security_type, security_id).process
  end

  attr_reader :security_type, :security_id
  def initialize(security_type, security_id)
    @security_type = security_type
    @security_id = security_id
  end

  def process
    result = {}
    connection = Faraday.new(
      url: "#{ENV['DHAN_API_URL']}/marketfeed/ltp",
      headers: {
        'Content-Type' => 'application/json',
        'access-token' => ENV['DHAN_API_KEY'],
        'client-id' => ENV['DHAN_CLIENT_ID'].to_s
    })

    request_body = { "#{security_type}": [security_id.to_i] }.to_json

    response = connection.post do |req|
      req.body = request_body
    end

    body = JSON.parse(response.body, symbolize_names: true)
    result = if response.success?
      ltp = body.first[1].first[1].first[1].first[1]
      { success: true, ltp: ltp }
    else
      { success: false, error: body[:data].first[1] }
    end
    result
  end
end