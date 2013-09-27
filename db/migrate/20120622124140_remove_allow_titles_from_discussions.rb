class RemoveAllowTitlesFromDiscussions < ActiveRecord::Migration
  def up
    remove_column :discussions, :allows_title_replies
  end

  def down
    add_column :discussions, :allows_title_replies, default: true
  end
end
