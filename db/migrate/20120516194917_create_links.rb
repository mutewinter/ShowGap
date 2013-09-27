class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.string :name
      t.string :url
      t.integer :state, default: 0
      t.integer :topic_id

      t.timestamps
    end
    add_index :links, :topic_id
  end
end
