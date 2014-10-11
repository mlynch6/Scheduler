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

ActiveRecord::Schema.define(:version => 20141011053113) do

  create_table "accounts", :force => true do |t|
    t.string   "name",                         :limit => 100, :null => false
    t.string   "time_zone",                    :limit => 100, :null => false
    t.string   "status",                       :limit => 20,  :null => false
    t.datetime "cancelled_at"
    t.string   "stripe_customer_token",        :limit => 100
    t.integer  "current_subscription_plan_id",                :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
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

  create_table "agma_contracts", :force => true do |t|
    t.integer  "account_id",                 :null => false
    t.integer  "rehearsal_start_min",        :null => false
    t.integer  "rehearsal_end_min",          :null => false
    t.integer  "rehearsal_max_hrs_per_week", :null => false
    t.integer  "rehearsal_max_hrs_per_day",  :null => false
    t.integer  "rehearsal_increment_min",    :null => false
    t.integer  "class_break_min",            :null => false
    t.integer  "costume_increment_min"
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
    t.integer  "demo_max_duration"
    t.integer  "demo_max_num_per_day"
  end

  add_index "agma_contracts", ["account_id"], :name => "index_agma_contracts_on_account_id", :unique => true

  create_table "appearances", :force => true do |t|
    t.integer  "scene_id",     :null => false
    t.integer  "character_id", :null => false
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "appearances", ["character_id"], :name => "index_appearances_on_character_id"
  add_index "appearances", ["scene_id", "character_id"], :name => "index_appearances_on_scene_id_and_character_id", :unique => true
  add_index "appearances", ["scene_id"], :name => "index_appearances_on_scene_id"

  create_table "castings", :force => true do |t|
    t.integer  "account_id",   :null => false
    t.integer  "cast_id",      :null => false
    t.integer  "character_id", :null => false
    t.integer  "person_id"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
  end

  add_index "castings", ["account_id"], :name => "index_castings_on_account_id"
  add_index "castings", ["cast_id", "character_id"], :name => "index_castings_on_cast_id_and_character_id", :unique => true
  add_index "castings", ["cast_id"], :name => "index_castings_on_cast_id"
  add_index "castings", ["character_id"], :name => "index_castings_on_character_id"
  add_index "castings", ["person_id"], :name => "index_castings_on_person_id"

  create_table "casts", :force => true do |t|
    t.integer  "account_id",                    :null => false
    t.integer  "season_piece_id",               :null => false
    t.string   "name",            :limit => 20, :null => false
    t.datetime "created_at",                    :null => false
    t.datetime "updated_at",                    :null => false
  end

  add_index "casts", ["account_id"], :name => "index_casts_on_account_id"
  add_index "casts", ["season_piece_id", "name"], :name => "index_casts_on_season_piece_id_and_name", :unique => true

  create_table "characters", :force => true do |t|
    t.integer  "account_id",                                  :null => false
    t.integer  "piece_id",                                    :null => false
    t.string   "name",       :limit => 30,                    :null => false
    t.integer  "position",                                    :null => false
    t.datetime "created_at",                                  :null => false
    t.datetime "updated_at",                                  :null => false
    t.string   "gender",     :limit => 10
    t.boolean  "animal",                   :default => false, :null => false
    t.boolean  "is_child",                 :default => false, :null => false
    t.boolean  "speaking",                 :default => false, :null => false
    t.boolean  "deleted",                  :default => false, :null => false
    t.datetime "deleted_at"
  end

  add_index "characters", ["account_id"], :name => "index_characters_on_account_id"
  add_index "characters", ["piece_id"], :name => "index_characters_on_piece_id"

  create_table "company_classes", :force => true do |t|
    t.integer  "account_id",                                   :null => false
    t.integer  "season_id",                                    :null => false
    t.string   "title",       :limit => 30,                    :null => false
    t.text     "comment"
    t.datetime "start_at",                                     :null => false
    t.integer  "duration",                                     :null => false
    t.date     "end_date",                                     :null => false
    t.integer  "location_id",                                  :null => false
    t.boolean  "monday",                    :default => false, :null => false
    t.boolean  "tuesday",                   :default => false, :null => false
    t.boolean  "wednesday",                 :default => false, :null => false
    t.boolean  "thursday",                  :default => false, :null => false
    t.boolean  "friday",                    :default => false, :null => false
    t.boolean  "saturday",                  :default => false, :null => false
    t.boolean  "sunday",                    :default => false, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "company_classes", ["account_id"], :name => "index_company_classes_on_account_id"
  add_index "company_classes", ["location_id"], :name => "index_company_classes_on_location_id"
  add_index "company_classes", ["season_id"], :name => "index_company_classes_on_season_id"

  create_table "costume_fittings", :force => true do |t|
    t.integer  "account_id",               :null => false
    t.integer  "season_id",                :null => false
    t.string   "title",      :limit => 30, :null => false
    t.text     "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "costume_fittings", ["account_id"], :name => "index_costume_fittings_on_account_id"
  add_index "costume_fittings", ["season_id"], :name => "index_costume_fittings_on_season_id"

  create_table "dropdowns", :force => true do |t|
    t.string   "dropdown_type", :limit => 30,                   :null => false
    t.string   "name",          :limit => 30,                   :null => false
    t.text     "comment"
    t.integer  "position",                                      :null => false
    t.boolean  "active",                      :default => true, :null => false
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
  end

  add_index "dropdowns", ["dropdown_type", "name"], :name => "index_dropdowns_on_dropdown_type_and_name", :unique => true
  add_index "dropdowns", ["dropdown_type"], :name => "index_dropdowns_on_dropdown_type"

  create_table "employees", :force => true do |t|
    t.integer  "account_id",                                             :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
    t.string   "employee_num",          :limit => 20
    t.date     "employment_start_date"
    t.date     "employment_end_date"
    t.text     "biography"
    t.string   "job_title",             :limit => 50
    t.boolean  "agma_artist",                         :default => false, :null => false
  end

  add_index "employees", ["account_id"], :name => "index_employees_on_account_id"

  create_table "events", :force => true do |t|
    t.integer  "account_id",                     :null => false
    t.integer  "schedulable_id",                 :null => false
    t.string   "schedulable_type",               :null => false
    t.string   "title",            :limit => 30, :null => false
    t.integer  "location_id"
    t.datetime "start_at",                       :null => false
    t.datetime "end_at",                         :null => false
    t.text     "comment"
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  add_index "events", ["account_id"], :name => "index_events_on_account_id"
  add_index "events", ["location_id"], :name => "index_events_on_location_id"
  add_index "events", ["schedulable_id", "schedulable_type"], :name => "index_events_on_schedulable_id_and_schedulable_type"

  create_table "invitations", :force => true do |t|
    t.integer  "event_id",   :null => false
    t.integer  "person_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "invitations", ["event_id", "person_id"], :name => "index_invitations_on_event_id_and_employee_id", :unique => true
  add_index "invitations", ["event_id"], :name => "index_invitations_on_event_id"
  add_index "invitations", ["person_id"], :name => "index_invitations_on_employee_id"

  create_table "lecture_demos", :force => true do |t|
    t.integer  "account_id",               :null => false
    t.integer  "season_id",                :null => false
    t.string   "title",      :limit => 30, :null => false
    t.text     "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "lecture_demos", ["account_id"], :name => "index_lecture_demos_on_account_id"
  add_index "lecture_demos", ["season_id"], :name => "index_lecture_demos_on_season_id"

  create_table "locations", :force => true do |t|
    t.integer  "account_id",                                 :null => false
    t.string   "name",       :limit => 50,                   :null => false
    t.boolean  "active",                   :default => true, :null => false
    t.datetime "created_at",                                 :null => false
    t.datetime "updated_at",                                 :null => false
  end

  add_index "locations", ["account_id", "name"], :name => "index_locations_on_account_id_and_name", :unique => true
  add_index "locations", ["account_id"], :name => "index_locations_on_account_id"

  create_table "people", :force => true do |t|
    t.integer  "account_id",                                   :null => false
    t.integer  "profile_id",                                   :null => false
    t.string   "profile_type", :limit => 50,                   :null => false
    t.string   "first_name",   :limit => 30,                   :null => false
    t.string   "middle_name",  :limit => 30
    t.string   "last_name",    :limit => 30,                   :null => false
    t.string   "suffix",       :limit => 10
    t.string   "gender",       :limit => 10
    t.date     "birth_date"
    t.string   "email",        :limit => 50
    t.boolean  "active",                     :default => true, :null => false
    t.datetime "created_at",                                   :null => false
    t.datetime "updated_at",                                   :null => false
  end

  add_index "people", ["account_id"], :name => "index_people_on_account_id"
  add_index "people", ["profile_id", "profile_type"], :name => "index_people_on_profile_id_and_profile_type"

  create_table "permissions", :force => true do |t|
    t.integer  "account_id", :null => false
    t.integer  "user_id",    :null => false
    t.integer  "role_id",    :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "permissions", ["account_id", "user_id", "role_id"], :name => "index_permissions_on_account_id_and_user_id_and_role_id", :unique => true
  add_index "permissions", ["account_id"], :name => "index_permissions_on_account_id"
  add_index "permissions", ["role_id"], :name => "index_permissions_on_role_id"
  add_index "permissions", ["user_id"], :name => "index_permissions_on_user_id"

  create_table "phones", :force => true do |t|
    t.integer  "phoneable_id",                                    :null => false
    t.string   "phoneable_type",                                  :null => false
    t.string   "phone_type",     :limit => 20,                    :null => false
    t.string   "phone_num",      :limit => 13,                    :null => false
    t.boolean  "primary",                      :default => false, :null => false
    t.datetime "created_at",                                      :null => false
    t.datetime "updated_at",                                      :null => false
  end

  add_index "phones", ["phoneable_id", "phoneable_type"], :name => "index_phones_on_phoneable_id_and_phoneable_type"

  create_table "pieces", :force => true do |t|
    t.integer  "account_id",                  :null => false
    t.string   "name",          :limit => 50, :null => false
    t.string   "choreographer", :limit => 50
    t.string   "music",         :limit => 50
    t.string   "composer",      :limit => 50
    t.integer  "avg_length"
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "pieces", ["account_id", "name", "choreographer"], :name => "index_pieces_on_account_id_and_name_and_choreographer", :unique => true
  add_index "pieces", ["account_id"], :name => "index_pieces_on_account_id"

  create_table "rehearsal_breaks", :force => true do |t|
    t.integer  "agma_contract_id", :null => false
    t.integer  "break_min",        :null => false
    t.integer  "duration_min",     :null => false
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

  add_index "rehearsal_breaks", ["agma_contract_id", "duration_min"], :name => "index_rehearsal_breaks_on_agma_contract_id_and_duration_min", :unique => true
  add_index "rehearsal_breaks", ["agma_contract_id"], :name => "index_rehearsal_breaks_on_agma_contract_id"

  create_table "rehearsals", :force => true do |t|
    t.integer  "account_id",               :null => false
    t.integer  "season_id",                :null => false
    t.string   "title",      :limit => 30, :null => false
    t.integer  "piece_id",                 :null => false
    t.integer  "scene_id"
    t.text     "comment"
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "rehearsals", ["account_id"], :name => "index_rehearsals_on_account_id"
  add_index "rehearsals", ["piece_id"], :name => "index_rehearsals_on_piece_id"
  add_index "rehearsals", ["scene_id"], :name => "index_rehearsals_on_scene_id"
  add_index "rehearsals", ["season_id"], :name => "index_rehearsals_on_season_id"

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

  create_table "season_pieces", :force => true do |t|
    t.integer  "account_id",                      :null => false
    t.integer  "season_id",                       :null => false
    t.integer  "piece_id",                        :null => false
    t.boolean  "published",    :default => false, :null => false
    t.datetime "published_at"
    t.datetime "created_at",                      :null => false
    t.datetime "updated_at",                      :null => false
  end

  add_index "season_pieces", ["account_id"], :name => "index_season_pieces_on_account_id"
  add_index "season_pieces", ["piece_id"], :name => "index_season_pieces_on_piece_id"
  add_index "season_pieces", ["season_id", "piece_id"], :name => "index_season_pieces_on_season_id_and_piece_id", :unique => true
  add_index "season_pieces", ["season_id"], :name => "index_season_pieces_on_season_id"

  create_table "seasons", :force => true do |t|
    t.integer  "account_id",               :null => false
    t.string   "name",       :limit => 30, :null => false
    t.date     "start_dt",                 :null => false
    t.date     "end_dt",                   :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "seasons", ["account_id"], :name => "index_seasons_on_account_id"

  create_table "subscription_plans", :force => true do |t|
    t.string   "name",       :limit => 50,                               :null => false
    t.decimal  "amount",                   :precision => 7, :scale => 2, :null => false
    t.datetime "created_at",                                             :null => false
    t.datetime "updated_at",                                             :null => false
  end

  create_table "users", :force => true do |t|
    t.integer  "account_id",                                              :null => false
    t.integer  "person_id",                                               :null => false
    t.string   "username",               :limit => 20,                    :null => false
    t.string   "password_digest",                                         :null => false
    t.datetime "created_at",                                              :null => false
    t.datetime "updated_at",                                              :null => false
    t.string   "password_reset_token",   :limit => 50
    t.datetime "password_reset_sent_at"
    t.boolean  "superadmin",                           :default => false, :null => false
  end

  add_index "users", ["account_id"], :name => "index_users_on_account_id"
  add_index "users", ["person_id"], :name => "index_users_on_employee_id"
  add_index "users", ["username"], :name => "index_users_on_username", :unique => true

end
