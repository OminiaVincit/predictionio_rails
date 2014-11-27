class AddApiRpmToUsers < ActiveRecord::Migration
  def change
    add_column :users, :api_rpm, :integer
  end
end
