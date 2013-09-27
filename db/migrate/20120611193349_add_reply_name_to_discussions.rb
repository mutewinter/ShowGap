class AddReplyNameToDiscussions < ActiveRecord::Migration
  def change
    add_column :discussions, :reply_name, :string, default: 'Reply'
  end
end
