# frozen_string_literal: true

ActiveRecord::Schema.define(version: 20_261_112_000_000) do
  create_table :things, force: :cascade do |t|
    t.string :name, null: false
    t.string :code
    t.timestamps
  end
end
