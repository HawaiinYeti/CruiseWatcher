class RoomFeature < ApplicationRecord
  has_many :room_feature_memberships, dependent: :destroy
  has_many :rooms, through: :room_feature_memberships

  before_save :update_regex_matchers

  def update_regex_matchers
    return unless regex_matchers.is_a?(String)

    self.regex_matchers = regex_matchers.split(',').map { |r| Regexp.new(r) }.to_yaml
  end

  def regex_matchers
    Psych.safe_load(self[:regex_matchers], permitted_classes: [Regexp])
  end
end
