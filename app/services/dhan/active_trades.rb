class Dhan::ActiveTrades
  def self.call
    result = {}
    connection = Faraday.new(
      url: "#{ENV['DHAN_API_URL']}/positions",
      headers: {
        'Content-Type' => 'application/json',
        'access-token' => ENV['DHAN_API_KEY']
    })
  
    response = connection.get
    body = JSON.parse(response.body, symbolize_names: true)

    result = if response.success?
      { success: true, positions: body }
    else
      { success: false, error: body[:errorMessage] }
    end
    result
  end
end