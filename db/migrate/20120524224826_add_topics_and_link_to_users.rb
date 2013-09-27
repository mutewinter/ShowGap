class AddTopicsAndLinkToUsers < ActiveRecord::Migration
  def change
    add_column :topics, :author_id, :integer
    add_index :topics, :author_id

    add_column :links, :author_id, :integer
    add_index :links, :author_id
  end
end
