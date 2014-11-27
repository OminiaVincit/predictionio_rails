class CreateApps < ActiveRecord::Migration
  def change
    create_table :apps do |t|
      t.string :api_key
      t.string :name

      t.timestamps
    end
  end
end
