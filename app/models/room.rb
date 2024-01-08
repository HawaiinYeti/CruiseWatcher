class Room < ApplicationRecord
  belongs_to :sailing
  has_one :ship, through: :sailing
  has_one :cruise, through: :sailing

  has_many :room_feature_memberships, dependent: :destroy
  has_many :room_features, through: :room_feature_memberships
  has_many :room_pricings, dependent: :destroy

  before_save :update_room_features
  after_save :stamp_room_pricings

  def update_room_features
    features = RoomFeature.all.map do |room_feature|
      room_feature if room_feature.regex_matchers.any? { |regex_matcher| regex_matcher.match?(name) }
    end.compact.uniq

    self.room_features = features
  end

  def features
    room_features.map(&:feature_name).sort.join(', ')
  end

  def stamp_room_pricings
    return unless saved_change_to_price?

    room_pricings.find_or_create_by(
      timestamp: Time.zone.now.beginning_of_hour,
      sailing: sailing
    ).update(
      price: price
    )
  end
end
