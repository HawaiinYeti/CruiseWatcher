class PortCruiseMembership < ApplicationRecord
  belongs_to :port
  belongs_to :cruise
end
