class CreateDiscussions < ActiveRecord::Migration
  def change
    create_table :discussions do |t|
      t.string :title
      t.text :body

      t.integer :episode_id

      t.integer :discussion_type_cd, default: 10

      t.boolean :allows_title_responses, default: true
      t.boolean :allows_url_responses, default: true
      t.boolean :allows_text_responses, default: true

      t.boolean :voting_open, default: true
      t.boolean :responses_open, default: true

      t.timestamps
    end

    add_index :discussions, :episode_id
  end
end
