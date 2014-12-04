class RemoveCounterCacheToUsers < ActiveRecord::Migration
  def change
    remove_column :users, :reviews_count, :integer
  end
end
