class Ship < ApplicationRecord
  has_many :cruises, dependent: :destroy
  has_many :rooms, dependent: :destroy
  has_many :sailings, through: :cruises
end
