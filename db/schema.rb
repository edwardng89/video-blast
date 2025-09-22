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

ActiveRecord::Schema[7.1].define(version: 2025_09_16_051302) do
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

  create_table "actors", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.date "birth_date"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "dob"
  end

  create_table "castings", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "actor_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "ix_castings_on_actor_id"
    t.index ["movie_id"], name: "ix_castings_on_movie_id"
  end

  create_table "communication_records", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.text "body"
    t.integer "communication_recordable_id"
    t.string "communication_recordable_type"
    t.string "from"
    t.datetime "received_at"
    t.datetime "sent_at"
    t.string "subject"
    t.string "to"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "copies", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.string "copy_format", null: false
    t.string "status", default: "available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "no_of_copies"
    t.boolean "active"
    t.integer "rental_cost"
    t.datetime "deleted_at"
    t.index ["movie_id"], name: "ix_copies_on_movie_id"
  end

  create_table "froala_assets", force: :cascade do |t|
    t.string "file", null: false
    t.string "file_name"
    t.string "content_type"
    t.integer "file_size"
    t.string "type", limit: 30
    t.integer "width"
    t.integer "height"
    t.boolean "gallery"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["gallery"], name: "ix_froala_assets_on_gallery"
    t.index ["type"], name: "ix_froala_assets_on_type"
  end

  create_table "genres", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.string "name"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "mosaico_images", id: :serial, force: :cascade do |t|
    t.string "file", null: false
    t.integer "width", null: false
    t.integer "height", null: false
    t.integer "filesize", null: false
    t.string "mime_type", null: false
    t.string "type", null: false
    t.integer "parent_id"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "mosaico_projects", id: :serial, force: :cascade do |t|
    t.text "html"
    t.text "content"
    t.text "metadata"
    t.string "template_name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "movie_actors", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.integer "actor_id"
    t.integer "movie_id"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "ix_movie_actors_on_actor_id"
    t.index ["movie_id"], name: "ix_movie_actors_on_movie_id"
  end

  create_table "movie_copies", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.integer "copies"
    t.string "format"
    t.integer "movie_id"
    t.integer "rental_price_cents", default: 0, null: false
    t.string "rental_price_currency", default: "AUD", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "ix_movie_copies_on_movie_id"
  end

  create_table "movie_genres", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.integer "genre_id"
    t.integer "movie_id"
    t.integer "sort_order"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "ix_movie_genres_on_genre_id"
    t.index ["movie_id"], name: "ix_movie_genres_on_movie_id"
  end

  create_table "movie_notifications", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.date "canceled_on"
    t.integer "movie_copy_id"
    t.date "requested_on"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_copy_id"], name: "ix_movie_notifications_on_movie_copy_id"
    t.index ["user_id"], name: "ix_movie_notifications_on_user_id"
  end

  create_table "movies", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.string "content_rating"
    t.string "cover"
    t.text "description"
    t.date "released_on"
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.string "format"
    t.boolean "fulfilled", default: false
    t.datetime "notified_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "ix_notifications_on_movie_id"
    t.index ["user_id"], name: "ix_notifications_on_user_id"
  end

  create_table "order_movie_copies", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.integer "movie_copy_id"
    t.integer "order_id"
    t.date "returned_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_copy_id"], name: "ix_order_movie_copies_on_movie_copy_id"
    t.index ["order_id"], name: "ix_order_movie_copies_on_order_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.date "return_due"
    t.string "status"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "ix_orders_on_user_id"
  end

  create_table "ratings", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "movie_id", null: false
    t.integer "stars", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "ix_ratings_on_movie_id"
    t.index ["user_id"], name: "ix_ratings_on_user_id"
  end

  create_table "rental_items", force: :cascade do |t|
    t.bigint "rental_id", null: false
    t.bigint "copy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["copy_id"], name: "ix_rental_items_on_copy_id"
    t.index ["rental_id", "copy_id"], name: "ix_rental_items_on_rental_id__copy_id", unique: true
    t.index ["rental_id"], name: "ix_rental_items_on_rental_id"
  end

  create_table "rentals", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "order_number", null: false
    t.date "rental_date", null: false
    t.date "due_date"
    t.date "return_date"
    t.string "order_status", default: "ongoing"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "returned_at"
    t.datetime "overdue_notice_sent_at"
    t.datetime "overdue_escalation_sent_at"
    t.index ["order_number"], name: "ix_rentals_on_order_number", unique: true
    t.index ["user_id"], name: "ix_rentals_on_user_id"
  end

  create_table "user_ratings", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.integer "movie_id"
    t.integer "rating"
    t.integer "user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["movie_id"], name: "ix_user_ratings_on_movie_id"
  end

  create_table "users", force: :cascade do |t|
    t.integer "creator_id"
    t.integer "updater_id"
    t.datetime "deleted_at"
    t.boolean "active"
    t.string "address_line_1"
    t.string "address_line_2"
    t.boolean "admin"
    t.string "first_name"
    t.string "gender"
    t.string "last_name"
    t.string "postcode"
    t.string "role"
    t.string "state"
    t.string "suburb"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "invitation_token"
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer "invitation_limit"
    t.string "invited_by_type"
    t.bigint "invited_by_id"
    t.integer "invitations_count", default: 0
    t.integer "sign_in_count"
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.index ["email"], name: "ix_users_on_email", unique: true
    t.index ["invitation_token"], name: "ix_users_on_invitation_token", unique: true
    t.index ["invited_by_id"], name: "ix_users_on_invited_by_id"
    t.index ["invited_by_type", "invited_by_id"], name: "index_users_on_invited_by"
    t.index ["reset_password_token"], name: "ix_users_on_reset_password_token", unique: true
  end

  create_table "video_genres", force: :cascade do |t|
    t.bigint "movie_id", null: false
    t.bigint "genre_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["genre_id"], name: "ix_video_genres_on_genre_id"
    t.index ["movie_id"], name: "ix_video_genres_on_movie_id"
  end

  create_table "videos", force: :cascade do |t|
    t.string "title", null: false
    t.date "released_date"
    t.text "description"
    t.string "content_rating"
    t.float "avg_user_ratings", default: 0.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "castings", "actors"
  add_foreign_key "castings", "movies"
  add_foreign_key "copies", "movies"
  add_foreign_key "notifications", "movies"
  add_foreign_key "notifications", "users"
  add_foreign_key "ratings", "movies"
  add_foreign_key "ratings", "users"
  add_foreign_key "rental_items", "copies"
  add_foreign_key "rental_items", "rentals"
  add_foreign_key "rentals", "users"
  add_foreign_key "video_genres", "genres"
  add_foreign_key "video_genres", "movies"
end
