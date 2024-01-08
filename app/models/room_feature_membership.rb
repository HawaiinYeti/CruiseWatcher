class RoomFeatureMembership < ApplicationRecord
  belongs_to :room
  belongs_to :room_feature
end
