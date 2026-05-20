class ChangeTitleTargetUrlInShorturls < ActiveRecord::Migration[8.1]
  def change
    change_column :shorturls, :title, :text
    change_column :shorturls, :target_url, :text
  end
end
