class RemoveShortUrlCodeFromShorturls < ActiveRecord::Migration[8.1]
  def change
    remove_column :shorturls, :short_url_code, :string
  end
end
