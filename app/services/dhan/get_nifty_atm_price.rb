class Dhan::GetNiftyAtmPrice
  require 'csv'
  def self.call(option_type, price)
    new(option_type, price).process
  end

  attr_reader :option_type, :price
  def initialize(option_type, price)
    @option_type = option_type
    @price = price
  end

  def process
    atm_option = find_atm_by_price(price)
    symbol = "NIFTY #{ENV['NIFTY_EXPIRY_DATE']} #{atm_option.to_i} #{option_type}"
    security_id = get_security_id(symbol)
    result = Dhan::GetPriceQuote.call("NSE_FNO", security_id)
    result[:security_id] = security_id
    result[:symbol] = symbol
    result
  end

  private

  def find_atm_by_price(price)
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
end  
