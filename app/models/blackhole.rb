class Blackhole < ApplicationRecord
  validates :path, uniqueness: true, length: { in: 0..255 }
end
