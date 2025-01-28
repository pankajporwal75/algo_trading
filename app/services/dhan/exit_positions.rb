class Dhan::ExitPositions
  def self.call(positions)
    new(positions).process
  end

  attr_reader :positions
  def initialize(positions)
    @positions = positions
  end

  def process
    active_positions = positions.select { |position| position[:positionType] == "LONG" }
    active_positions.each do |position|
      security_id = position[:securityId]
      quantity = position[:netQty]
      result = Dhan::PlaceOrder.call('SELL', security_id, quantity)
      return { success: false, error: result[:error] } if !result[:success]
    end
    { success: true }
  end
end