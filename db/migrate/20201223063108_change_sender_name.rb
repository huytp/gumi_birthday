class ChangeSenderName < ActiveRecord::Migration[6.0]
  def change
    rename_column :messages, :sendername, :sender_name
  end
end
