class Organization < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, :use => :slugged

  attr_accessible :name, :description, :url, :logo_image
  has_many :memberships
  has_many :members, :through => :memberships, :source => :user
  has_many :member_topics, :through => :members, :source => :topics

  mount_uploader :logo_image, LogoImageUploader
end
