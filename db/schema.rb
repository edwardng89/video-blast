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

ActiveRecord::Schema[7.1].define(version: 2024_02_29_051637) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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

end
