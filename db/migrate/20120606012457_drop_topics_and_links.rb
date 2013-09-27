class DropTopicsAndLinks < ActiveRecord::Migration
  def up
    drop_table :topics
    drop_table :links
  end

  def down
    create_table "links", :force => true do |t|
      t.string   "name"
      t.string   "url"
      t.integer  "state",      :default => 30
      t.integer  "topic_id"
      t.datetime "created_at",                 :null => false
      t.datetime "updated_at",                 :null => false
      t.integer  "author_id"
    end

    add_index "links", ["author_id"], :name => "index_links_on_author_id"
    add_index "links", ["topic_id"], :name => "index_links_on_topic_id"

    create_table "topics", :force => true do |t|
      t.string   "name"
      t.datetime "created_at", :null => false
      t.datetime "updated_at", :null => false
      t.integer  "show_id"
      t.text     "body"
      t.integer  "author_id"
    end

    add_index "topics", ["author_id"], :name => "index_topics_on_author_id"
    add_index "topics", ["show_id"], :name => "index_topics_on_show_id"
  end
end
