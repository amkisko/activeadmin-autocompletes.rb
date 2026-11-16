# frozen_string_literal: true

ActiveRecord::Schema.define(version: 20_261_116_000_000) do
  create_table :active_admin_comments, force: :cascade do |t|
    t.string :namespace
    t.text :body
    t.string :resource_id, null: false
    t.string :resource_type, null: false
    t.references :author, polymorphic: true
    t.timestamps
  end

  create_table :admin_users, force: :cascade do |t|
    t.string :email, null: false
    t.string :name
    t.timestamps
  end

  create_table :things, force: :cascade do |t|
    t.string :name, null: false
    t.string :code
    t.timestamps
  end
end
