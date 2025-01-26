class AccountsController < ApplicationController
  before_action :set_account, only: %i[ edit update ]

  # GET /accounts or /accounts.json
  def index
    @accounts = Account.all
  end

  def edit
  end

  def update
    respond_to do |format|
      if @account.update(account_params)
        format.html { redirect_to accounts_path, notice: "Account was successfully updated." }
        format.json { render :show, status: :ok, location: @account }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @account.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @account = Account.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def account_params
      params.require(:account).permit(:access_token, :account_id, :capital)
    end
end
