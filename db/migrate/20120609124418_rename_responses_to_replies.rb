class RenameResponsesToReplies < ActiveRecord::Migration
  def up
    # Responses Table
    rename_column :responses, :response_state_cd, :reply_state_cd
    remove_index :responses, :discussion_id

    rename_table :responses, :replies
    add_index :replies, :discussion_id

    # Discussion Table
    rename_column :discussions, :allows_title_responses, :allows_title_replies
    rename_column :discussions, :allows_url_responses, :allows_url_replies
    rename_column :discussions, :allows_text_responses, :allows_text_replies
    rename_column :discussions, :responses_open, :replies_open
  end

  def down
    # Replies Table
    rename_column :replies, :reply_state_cd, :response_state_cd
    remove_index :replies, :discussion_id

    rename_table :replies, :responses
    add_index :responses, :discussion_id

    # Discussion Table
    rename_column :discussions, :allows_title_replies, :allows_title_responses
    rename_column :discussions, :allows_url_replies, :allows_url_responses
    rename_column :discussions, :allows_text_replies, :allows_text_responses
    rename_column :discussions, :replies_open, :responses_open
  end
end
