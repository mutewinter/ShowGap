class AddUniqueRepliesToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :unique_replies, :boolean, default: false
  end
end
