class AddTopicsToShows < ActiveRecord::Migration
  def change
    add_column :topics, :show_id, :integer
    add_index :topics, :show_id
  end
end
