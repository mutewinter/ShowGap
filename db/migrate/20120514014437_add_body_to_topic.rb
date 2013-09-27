class AddBodyToTopic < ActiveRecord::Migration
  def change
    add_column :topics, :body, :text
  end
end
