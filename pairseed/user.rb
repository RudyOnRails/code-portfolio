class User < ActiveRecord::Base
  attr_accessible :first_name, :last_name, :username, :email, :password, :password_confirmation, :remember_me, :profile_attributes

  extend FriendlyId
  friendly_id :username, :use => :slugged

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :first_name, :last_name, :presence => true
  validates :first_name, :last_name, :format => { :with => /^[^0-9`!@#\$%\^&*+_=]+$/ }
  validates :username, :uniqueness => { :case_sensitive => false }
  validates :username, :format => { :with => /^[A-Za-z\d_]+$/ }
  validates :username, :exclusion => { :in => %w(admin superuser pairseed) }
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create }

  acts_as_taggable_on :organizations

  has_many :topics
  has_many :places
  has_many :memberships
  has_many :organizations, :through => :memberships
  has_many :organization_topics, :through => :organizations, :source => :member_topics, :uniq => true
  has_many :offers
  has_many :appointments
  has_one :profile  

  accepts_nested_attributes_for :profile

  after_create :send_email_to_kevin unless !Rails.env.production?

  def not_a_member?(organization_id)
    !self.organizations.include?(organization_id)
  end

  def has_not_offered_help?(topic_id, user_id)
    !Offer.where(:topic_id => topic_id, :user_id => user_id).exists?
  end

  def full_name
    first_name + " " + last_name
  end

  private
    def send_email_to_kevin
      AdministrationMailer.notify_onboarding_about_new_user(self).deliver
    end
end