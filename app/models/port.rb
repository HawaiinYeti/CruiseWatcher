class Port < ApplicationRecord
  has_many :port_cruise_memberships, dependent: :destroy
  has_many :cruises, through: :port_cruise_memberships
  has_many :ships, through: :cruises
  has_many :sailings, through: :cruises
end
