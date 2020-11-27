class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :articles

  before_save :substitute_whitespace

  private

  def substitute_whitespace
    name.gsub!(/\s+/, '-')
  end
end
