class CreateAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :accounts do |t|
      t.references :client, foreign_key: true
      t.decimal :balance, :precision => 8, :scale => 2

      t.timestamps
    end
  end
end
