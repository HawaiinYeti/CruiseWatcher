class Cruise < ApplicationRecord
  belongs_to :ship
  has_many :sailings, dependent: :destroy
  has_many :port_cruise_memberships, dependent: :destroy
  has_many :ports, through: :port_cruise_memberships
end
