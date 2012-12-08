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

ActiveRecord::Schema.define(:version => 20121207144539) do

  create_table "accounts", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.string   "main_phone", :limit => 13,  :null => false
    t.string   "time_zone",  :limit => 100, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "employees", :force => true do |t|
    t.integer  "account_id",                                 :null => false
    t.string   "first_name", :limit => 30,                   :null => false
    t.string   "last_name",  :limit => 30,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.string   "job_title",  :limit => 50
    t.string   "email",      :limit => 50
    t.string   "phone",      :limit => 13
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "employees", ["account_id"], :name => "index_employees_on_account_id"

  create_table "events", :force => true do |t|
    t.string   "title",       :limit => 30, :null => false
    t.string   "event_type",  :limit => 20, :null => false
    t.integer  "location_id",               :null => false
    t.datetime "start_at",                  :null => false
    t.datetime "end_at",                    :null => false
    t.integer  "piece_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "events", ["location_id"], :name => "index_events_on_location_id"
  add_index "events", ["piece_id"], :name => "index_events_on_piece_id"

  create_table "locations", :force => true do |t|
    t.string   "name",       :limit => 50,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "pieces", :force => true do |t|
    t.string   "name",       :limit => 50,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "roles", :force => true do |t|
    t.string   "name",       :limit => 30, :null => false
    t.integer  "piece_id",                 :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "roles", ["piece_id"], :name => "index_roles_on_piece_id"

  create_table "scenes", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.integer  "order_num",                 :null => false
    t.integer  "piece_id",                  :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "scenes", ["piece_id"], :name => "index_scenes_on_piece_id"

  create_table "users", :force => true do |t|
    t.integer  "account_id",                    :null => false
    t.string   "username",        :limit => 20, :null => false
    t.string   "password_digest",               :null => false
    t.string   "role",            :limit => 20, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
