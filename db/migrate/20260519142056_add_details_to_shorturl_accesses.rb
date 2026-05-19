class AddDetailsToShorturlAccesses < ActiveRecord::Migration[8.1]
  def change
    add_column :shorturl_accesses, :ip, :string
    add_column :shorturl_accesses, :referer, :string
  end
end
