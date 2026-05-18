class CreateShorturlAccesses < ActiveRecord::Migration[8.1]
  def change
    create_table :shorturl_accesses do |t|
      t.references :shorturl, null: false, foreign_key: true
      t.text :geolocation
      t.datetime :timestamp

      t.timestamps
    end
  end
end
