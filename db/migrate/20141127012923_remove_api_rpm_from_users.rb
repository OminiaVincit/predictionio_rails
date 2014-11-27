class RemoveApiRpmFromUsers < ActiveRecord::Migration
  def change
    remove_column :users, :api_rpm, :integer
  end
end
