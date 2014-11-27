class AddApiRpmToApps < ActiveRecord::Migration
  def change
    add_column :apps, :api_rpm, :string
  end
end
