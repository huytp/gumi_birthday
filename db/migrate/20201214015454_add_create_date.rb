class AddCreateDate < ActiveRecord::Migration[6.0]
  def change
    add_column :messages, :create_date, :date
  end
end
