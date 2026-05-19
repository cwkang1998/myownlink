class Shorturl < ApplicationRecord
  validates :title, presence: true
  validates :target_url, presence: true, target_url: true


  def short_url_code
    return nil unless id

    Base62.encode(id)
  end
end
