class TradesController < ApplicationController
  def buy
    flash[:notice] = 'Buy Order Successfull.'
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
end
