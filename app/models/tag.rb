class Tag < ApplicationRecord
  validates :name, presence: true, uniqueness: true

  has_and_belongs_to_many :articles

  before_save :substitute_whitespace

  scope :ordered, -> { order(id: :asc) }

  private

  def substitute_whitespace
    name.gsub!(/\s+/, '-')
  end
end
