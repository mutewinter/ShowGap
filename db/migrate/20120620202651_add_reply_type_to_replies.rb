class AddReplyTypeToReplies < ActiveRecord::Migration
  def change
    add_column :replies, :reply_type_cd, :integer, default: 10
  end
end
