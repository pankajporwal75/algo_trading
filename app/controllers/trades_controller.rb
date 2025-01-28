class TradesController < ApplicationController

  def buy
    active_trades = Dhan::ActiveTrades.call
    return initialize_failure_response(active_trades[:error]) if !active_trades[:success]
    
    exit_positions = Dhan::ExitPositions.call(active_trades[:positions])
    return initialize_failure_response(exit_positions[:error]) if !exit_positions[:success]
    
    nifty_price = Dhan::GetPriceQuote.call("IDX_I", 13)
    return initialize_failure_response(nifty_price[:error]) if !nifty_price[:success]
  
    atm_price = Dhan::GetNiftyAtmPrice.call("CALL", nifty_price[:ltp])
    return initialize_failure_response(atm_price[:error]) if !atm_price[:success]
    
    quantities = ENV['CAPITAL'].to_i / atm_price[:ltp]
    return initialize_failure_response("Capital is not sufficient to buy 1 lots (25 Shares).") if quantities < 25
    
    buy_quantities = get_quantities_for_set_capital(atm_price[:ltp]) # Margin for brokerage
    
    new_order = Dhan::PlaceOrder.call("BUY", atm_price[:security_id], buy_quantities)
    return initialize_failure_response(new_order[:error]) if !new_order[:success]
  
    redirect_to root_path, notice: "Buy Order Placed for #{atm_price[:symbol]}, QTY: #{buy_quantities}"
  end
  
  def sell
    active_trades = Dhan::ActiveTrades.call
    return initialize_failure_response(active_trades[:error]) if !active_trades[:success]
    
    exit_positions = Dhan::ExitPositions.call(active_trades[:positions])
    return initialize_failure_response(exit_positions[:error]) if !exit_positions[:success]
    
    nifty_price = Dhan::GetPriceQuote.call("IDX_I", 13)
    return initialize_failure_response(nifty_price[:error]) if !nifty_price[:success]
  
    atm_price = Dhan::GetNiftyAtmPrice.call("PUT", nifty_price[:ltp])
    return initialize_failure_response(atm_price[:error]) if !atm_price[:success]
    
    quantities = ENV['CAPITAL'].to_i / atm_price[:ltp]
    return initialize_failure_response("Capital is not sufficient to buy 1 lots (25 Shares).") if quantities < 25
    
    buy_quantities = get_quantities_for_set_capital(atm_price[:ltp]) # Margin for brokerage
    
    new_order = Dhan::PlaceOrder.call("BUY", atm_price[:security_id], buy_quantities)
    return initialize_failure_response(new_order[:error]) if !new_order[:success]
  
    redirect_to root_path, notice: "Buy Order Placed for #{atm_price[:symbol]}, QTY: #{buy_quantities}"
  end
  
  def square_off
    active_trades = Dhan::ActiveTrades.call
    return initialize_failure_response(active_trades[:error]) if !active_trades[:success]

    running_positions = get_running_positions(active_trades[:positions])
    return initialize_failure_response("No active positions.") if running_positions.blank?

    exit_positions = Dhan::ExitPositions.call(active_trades[:positions])
    return initialize_failure_response(exit_positions[:error]) if !exit_positions[:success]

    redirect_to root_path, notice: "All positions closed."
  end
  
  def reverse
    active_trades = Dhan::ActiveTrades.call
    return initialize_failure_response(active_trades[:error]) if !active_trades[:success]
    
    running_positions = get_running_positions(active_trades[:positions])
    return initialize_failure_response("No active positions found to be reversed.") if running_positions.blank?

    exit_positions = Dhan::ExitPositions.call(active_trades[:positions])
    return initialize_failure_response(exit_positions[:error]) if !exit_positions[:success]

    nifty_price = Dhan::GetPriceQuote.call("IDX_I", 13)
    return initialize_failure_response(nifty_price[:error]) if !nifty_price[:success]

    option_type = get_new_option_type(running_positions)

    atm_price = Dhan::GetNiftyAtmPrice.call(option_type, nifty_price[:ltp])
    return initialize_failure_response(atm_price[:error]) if !atm_price[:success]

    quantities = ENV['CAPITAL'].to_i / atm_price[:ltp]
    return initialize_failure_response("Capital is not sufficient to buy 1 lots (25 Shares).") if quantities < 25
    
    buy_quantities = get_quantities_for_set_capital(atm_price[:ltp]) # Margin for brokerage
    
    new_order = Dhan::PlaceOrder.call("BUY", atm_price[:security_id], buy_quantities)
    return initialize_failure_response(new_order[:error]) if !new_order[:success]
  
    redirect_to root_path, notice: "Buy Order Placed for #{atm_price[:symbol]}, QTY: #{buy_quantities}"
  end

  private

  def get_quantities_for_set_capital(price)
    amount = ENV['CAPITAL'].to_i - 200
    qty = (amount / price).floor
    lots = qty/25
    lots * 25
  end
  
  def initialize_failure_response(message)
    flash[:alert] = message
    redirect_to root_path and return
  end

  def get_running_positions(positions)
    positions.select { |position| position[:positionType] == "LONG" }
  end

  def get_new_option_type(positions)
    position = positions.first
    position[:drvOptionType] == "CALL" ? "PUT" : "CALL"
  end
end