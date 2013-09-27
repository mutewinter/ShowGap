# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120721124858) do

  create_table "discussions", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "episode_id"
    t.integer  "discussion_type_cd",  :default => 10
    t.boolean  "allows_url_replies",  :default => true
    t.boolean  "allows_text_replies", :default => true
    t.boolean  "voting_open",         :default => true
    t.boolean  "replies_open",        :default => true
    t.datetime "created_at",                               :null => false
    t.datetime "updated_at",                               :null => false
    t.string   "reply_name",          :default => "Reply"
    t.integer  "author_id"
    t.boolean  "unique_replies",      :default => false
  end

  add_index "discussions", ["author_id"], :name => "index_discussions_on_author_id"
  add_index "discussions", ["episode_id"], :name => "index_discussions_on_episode_id"

  create_table "episodes", :force => true do |t|
    t.string   "slug"
    t.integer  "state_cd",    :default => 10
    t.integer  "show_id"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
    t.string   "title"
    t.datetime "record_date"
  end

  add_index "episodes", ["show_id"], :name => "index_episodes_on_show_id"

  create_table "replies", :force => true do |t|
    t.string   "title"
    t.string   "text"
    t.integer  "reply_state_cd", :default => 10
    t.integer  "author_id"
    t.integer  "discussion_id"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
    t.integer  "reply_type_cd",  :default => 10
  end

  add_index "replies", ["discussion_id"], :name => "index_replies_on_discussion_id"

  create_table "shows", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "subdomain"
  end

  create_table "users", :force => true do |t|
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.string   "nickname"
    t.string   "description"
    t.string   "image"
    t.string   "website"
    t.string   "location"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.string   "role"
  end

  create_table "votes", :force => true do |t|
    t.boolean  "vote",          :default => false
    t.integer  "voteable_id",                      :null => false
    t.string   "voteable_type",                    :null => false
    t.integer  "voter_id"
    t.string   "voter_type"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "votes", ["voteable_id", "voteable_type"], :name => "index_votes_on_voteable_id_and_voteable_type"
  add_index "votes", ["voter_id", "voter_type", "voteable_id", "voteable_type"], :name => "fk_one_vote_per_user_per_entity", :unique => true
  add_index "votes", ["voter_id", "voter_type"], :name => "index_votes_on_voter_id_and_voter_type"

end
