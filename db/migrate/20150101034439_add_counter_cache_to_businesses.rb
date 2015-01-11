class AddCounterCacheToBusinesses < ActiveRecord::Migration
  def up
    add_column :businesses, :reviews_count, :integer, :default => 0
    
    Business.find_each do |business|
      Business.reset_counters(business.id, :reviews)
      puts "Updating count for #{business.id}."
    end
  end
  
  def down
    remove_column :businesses, :reviews_count
  end
end
