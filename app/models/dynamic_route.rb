class DynamicRoute < ApplicationRecord
  validates :path, uniqueness: true, length: { in: 0..255 }

  belongs_to :article
end
