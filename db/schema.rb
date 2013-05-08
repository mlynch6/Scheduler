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

ActiveRecord::Schema.define(:version => 20131207144542) do

  create_table "accounts", :force => true do |t|
    t.string   "name",       :limit => 100, :null => false
    t.string   "main_phone", :limit => 13,  :null => false
    t.string   "time_zone",  :limit => 100, :null => false
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  create_table "addresses", :force => true do |t|
    t.integer  "addressable_id",                 :null => false
    t.string   "addressable_type",               :null => false
    t.string   "addr_type",        :limit => 30, :null => false
    t.string   "addr",             :limit => 50, :null => false
    t.string   "addr2",            :limit => 50
    t.string   "city",             :limit => 50, :null => false
    t.string   "state",            :limit => 2,  :null => false
    t.string   "zipcode",          :limit => 5,  :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "agma_profiles", :force => true do |t|
    t.integer  "account_id",                 :null => false
    t.time     "rehearsal_start",            :null => false
    t.time     "rehearsal_end",              :null => false
    t.integer  "rehearsal_max_hrs_per_week", :null => false
    t.integer  "rehearsal_max_hrs_per_day",  :null => false
    t.integer  "rehearsal_increment_min",    :null => false
    t.integer  "class_break_min",            :null => false
    t.integer  "rehearsal_break_min_per_hr", :null => false
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  add_index "agma_profiles", ["account_id"], :name => "index_agma_profiles_on_account_id", :unique => true

  create_table "appearances", :force => true do |t|
    t.integer  "scene_id",     :null => false
    t.integer  "character_id", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "appearances", ["character_id"], :name => "index_appearances_on_character_id"
  add_index "appearances", ["scene_id", "character_id"], :name => "index_appearances_on_scene_id_and_character_id", :unique => true
  add_index "appearances", ["scene_id"], :name => "index_appearances_on_scene_id"

  create_table "characters", :force => true do |t|
    t.integer  "account_id",               :null => false
    t.integer  "piece_id",                 :null => false
    t.string   "name",       :limit => 30, :null => false
    t.integer  "position",                 :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "characters", ["account_id"], :name => "index_characters_on_account_id"
  add_index "characters", ["piece_id"], :name => "index_characters_on_piece_id"

  create_table "employees", :force => true do |t|
    t.integer  "account_id",                                 :null => false
    t.string   "first_name", :limit => 30,                   :null => false
    t.string   "last_name",  :limit => 30,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.string   "role",       :limit => 50,                   :null => false
    t.string   "email",      :limit => 50
    t.string   "phone",      :limit => 13
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "employees", ["account_id"], :name => "index_employees_on_account_id"

  create_table "events", :force => true do |t|
    t.integer  "account_id",                :null => false
    t.string   "title",       :limit => 30, :null => false
    t.string   "type",        :limit => 20, :null => false
    t.integer  "location_id",               :null => false
    t.datetime "start_at",                  :null => false
    t.datetime "end_at",                    :null => false
    t.integer  "piece_id"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "events", ["account_id"], :name => "index_events_on_account_id"
  add_index "events", ["location_id"], :name => "index_events_on_location_id"
  add_index "events", ["piece_id"], :name => "index_events_on_piece_id"

  create_table "invitations", :force => true do |t|
    t.integer  "event_id",    :null => false
    t.integer  "employee_id", :null => false
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "invitations", ["employee_id"], :name => "index_invitations_on_employee_id"
  add_index "invitations", ["event_id", "employee_id"], :name => "index_invitations_on_event_id_and_employee_id", :unique => true
  add_index "invitations", ["event_id"], :name => "index_invitations_on_event_id"

  create_table "locations", :force => true do |t|
    t.integer  "account_id",                                 :null => false
    t.string   "name",       :limit => 50,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "locations", ["account_id", "name"], :name => "index_locations_on_account_id_and_name", :unique => true
  add_index "locations", ["account_id"], :name => "index_locations_on_account_id"

  create_table "pieces", :force => true do |t|
    t.integer  "account_id",                                 :null => false
    t.string   "name",       :limit => 50,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "pieces", ["account_id", "name"], :name => "index_pieces_on_account_id_and_name", :unique => true
  add_index "pieces", ["account_id"], :name => "index_pieces_on_account_id"

  create_table "scenes", :force => true do |t|
    t.integer  "account_id",                :null => false
    t.integer  "piece_id",                  :null => false
    t.string   "name",       :limit => 100, :null => false
    t.integer  "position",                  :null => false
    t.string   "track",      :limit => 20
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "scenes", ["account_id"], :name => "index_scenes_on_account_id"
  add_index "scenes", ["piece_id"], :name => "index_scenes_on_piece_id"

  create_table "users", :force => true do |t|
    t.integer  "employee_id",                   :null => false
    t.string   "username",        :limit => 20, :null => false
    t.string   "password_digest",               :null => false
    t.string   "role",            :limit => 20, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "users", ["employee_id"], :name => "index_users_on_employee_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
