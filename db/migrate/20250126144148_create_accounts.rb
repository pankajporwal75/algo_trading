class CreateAccounts < ActiveRecord::Migration[7.1]
  def change
    create_table :accounts do |t|
      t.string :access_token
      t.integer :account_id
      t.float :capital

      t.timestamps
    end
  end
end
