class ChangeNameSenderName < ActiveRecord::Migration[6.0]
  def change
    rename_column :messages, :createdate, :create_date
  end
end
