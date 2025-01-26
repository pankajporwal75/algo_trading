class TradesController < ApplicationController
  before_action :get_active_trades, only: [:buy, :sell]
  BASE_URL = 'https://api.dhan.co/v2'

  def buy
    if @result[:success]
      flash[:notice] = 'Buy Order Successfull.'
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
end