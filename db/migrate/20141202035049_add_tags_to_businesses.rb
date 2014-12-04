class AddTagsToBusinesses < ActiveRecord::Migration
  def change
    add_column :businesses, :categories, :text
  end
end
