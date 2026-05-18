class CreateShorturls < ActiveRecord::Migration[8.1]
  def change
    create_table :shorturls do |t|
      t.string :title
      t.string :short_url_code, limit: 15
      t.string :target_url

      t.timestamps
    end
    add_index :shorturls, :short_url_code, unique: true
  end
end
