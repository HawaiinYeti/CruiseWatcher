class Sailing < ApplicationRecord
  belongs_to :ship
  belongs_to :cruise
  has_many :rooms, dependent: :destroy
end
