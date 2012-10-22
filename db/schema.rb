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

ActiveRecord::Schema.define(:version => 20121019174605) do

  create_table "locations", :force => true do |t|
    t.string   "name",       :limit => 50,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  create_table "performances", :force => true do |t|
    t.string   "name",                 :limit => 30, :null => false
    t.integer  "piece_id",                           :null => false
    t.date     "rehearsal_start_dt"
    t.date     "performance_start_dt",               :null => false
    t.date     "performance_end_dt",                 :null => false
    t.datetime "created_at",                         :null => false
    t.datetime "updated_at",                         :null => false
  end

  add_index "performances", ["piece_id"], :name => "index_performances_on_piece_id"

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

end
