class CreateResponses < ActiveRecord::Migration
  def change
    create_table :responses do |t|
      t.string :title
      t.string :text, length: 2500

      t.integer :response_state_cd, default: 10

      t.integer :author_id
      t.integer :discussion_id

      t.timestamps
    end

    add_index :responses, :discussion_id
  end
end
