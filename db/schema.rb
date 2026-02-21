# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_02_21_050003) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "agents", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "personality_summary"
    t.text "system_prompt"
    t.string "status", default: "active"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "match_cap_per_week", default: 5
    t.string "personality_mode", default: "friendly"
    t.string "name"
    t.boolean "autopilot", default: false
    t.index ["user_id"], name: "index_agents_on_user_id"
  end

  create_table "blocks", force: :cascade do |t|
    t.bigint "blocker_user_id", null: false
    t.bigint "blocked_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["blocked_user_id"], name: "index_blocks_on_blocked_user_id"
    t.index ["blocker_user_id", "blocked_user_id"], name: "index_blocks_on_blocker_user_id_and_blocked_user_id", unique: true
    t.index ["blocker_user_id"], name: "index_blocks_on_blocker_user_id"
  end

  create_table "chats", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "model_id"
    t.index ["model_id"], name: "index_chats_on_model_id"
  end

  create_table "date_events", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.bigint "venue_id"
    t.datetime "scheduled_time"
    t.string "booking_status"
    t.integer "rating_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id"], name: "index_date_events_on_match_id"
    t.index ["venue_id"], name: "index_date_events_on_venue_id"
  end

  create_table "match_transcripts", force: :cascade do |t|
    t.bigint "match_id", null: false
    t.string "stage", null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["match_id", "stage"], name: "index_match_transcripts_on_match_id_and_stage", unique: true
    t.index ["match_id"], name: "index_match_transcripts_on_match_id"
  end

  create_table "matches", force: :cascade do |t|
    t.bigint "initiator_agent_id", null: false
    t.bigint "receiver_agent_id", null: false
    t.decimal "compatibility_score"
    t.string "status"
    t.text "chat_transcript"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "compatibility_summary"
    t.index ["initiator_agent_id"], name: "index_matches_on_initiator_agent_id"
    t.index ["receiver_agent_id"], name: "index_matches_on_receiver_agent_id"
  end

  create_table "meetings", force: :cascade do |t|
    t.bigint "date_event_id", null: false
    t.bigint "venue_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date_event_id"], name: "index_meetings_on_date_event_id"
    t.index ["venue_id"], name: "index_meetings_on_venue_id"
  end

  create_table "messages", force: :cascade do |t|
    t.string "role", null: false
    t.text "content"
    t.json "content_raw"
    t.text "thinking_text"
    t.text "thinking_signature"
    t.integer "thinking_tokens"
    t.integer "input_tokens"
    t.integer "output_tokens"
    t.integer "cached_tokens"
    t.integer "cache_creation_tokens"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "chat_id", null: false
    t.bigint "model_id"
    t.bigint "tool_call_id"
    t.index ["chat_id"], name: "index_messages_on_chat_id"
    t.index ["model_id"], name: "index_messages_on_model_id"
    t.index ["role"], name: "index_messages_on_role"
    t.index ["tool_call_id"], name: "index_messages_on_tool_call_id"
  end

  create_table "models", force: :cascade do |t|
    t.string "model_id", null: false
    t.string "name", null: false
    t.string "provider", null: false
    t.string "family"
    t.datetime "model_created_at"
    t.integer "context_window"
    t.integer "max_output_tokens"
    t.date "knowledge_cutoff"
    t.jsonb "modalities", default: {}
    t.jsonb "capabilities", default: []
    t.jsonb "pricing", default: {}
    t.jsonb "metadata", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["capabilities"], name: "index_models_on_capabilities", using: :gin
    t.index ["family"], name: "index_models_on_family"
    t.index ["modalities"], name: "index_models_on_modalities", using: :gin
    t.index ["provider", "model_id"], name: "index_models_on_provider_and_model_id", unique: true
    t.index ["provider"], name: "index_models_on_provider"
  end

  create_table "tool_calls", force: :cascade do |t|
    t.string "tool_call_id", null: false
    t.string "name", null: false
    t.string "thought_signature"
    t.jsonb "arguments", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "message_id", null: false
    t.index ["message_id"], name: "index_tool_calls_on_message_id"
    t.index ["name"], name: "index_tool_calls_on_name"
    t.index ["tool_call_id"], name: "index_tool_calls_on_tool_call_id", unique: true
  end

  create_table "user_preferences", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "preferred_gender"
    t.integer "min_age"
    t.integer "max_age"
    t.integer "max_distance"
    t.string "preferred_education"
    t.string "preferred_zodiac_sign"
    t.string "preferred_mbti"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "budget_level"
    t.string "relationship_goal"
    t.string "alcohol"
    t.string "smoking"
    t.string "fitness"
    t.text "extras_json"
    t.jsonb "preferred_venue_types", default: []
    t.jsonb "schedule_availability", default: {}
    t.string "timezone", default: "UTC"
    t.index ["user_id"], name: "index_user_preferences_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "is_verified"
    t.string "first_name"
    t.string "last_name"
    t.string "city"
    t.string "country"
    t.string "pronouns"
    t.integer "height"
    t.date "date_of_birth"
    t.string "language"
    t.string "zodiac_sign"
    t.string "education"
    t.string "occupation"
    t.string "mbti"
    t.string "gender"
    t.text "bio"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "venues", force: :cascade do |t|
    t.string "name"
    t.string "address"
    t.string "city"
    t.string "venue_type"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.decimal "rating", precision: 3, scale: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "price_tier"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "agents", "users"
  add_foreign_key "blocks", "users", column: "blocked_user_id"
  add_foreign_key "blocks", "users", column: "blocker_user_id"
  add_foreign_key "chats", "models"
  add_foreign_key "date_events", "matches"
  add_foreign_key "date_events", "venues"
  add_foreign_key "match_transcripts", "matches"
  add_foreign_key "matches", "agents", column: "initiator_agent_id"
  add_foreign_key "matches", "agents", column: "receiver_agent_id"
  add_foreign_key "meetings", "date_events"
  add_foreign_key "meetings", "venues"
  add_foreign_key "messages", "chats"
  add_foreign_key "messages", "models"
  add_foreign_key "messages", "tool_calls"
  add_foreign_key "tool_calls", "messages"
  add_foreign_key "user_preferences", "users"
end
