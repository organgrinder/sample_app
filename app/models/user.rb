# == Schema Information
#
# Table name: users
#
#  id         :integer         not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

class User < ActiveRecord::Base
  attr_accessible :email, :name, :password, :password_confirmation
  has_secure_password
  has_many :microposts, dependent: :destroy

# has_secure_password automatically creates "validates"-type tests for password_digest field in the db
  
  before_save { |user| user.email = email.downcase }
  before_save :create_remember_token
  
  validates :name, presence: true, length: { maximum: 50 }
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, 
    uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }
  validates :password_confirmation, presence: true

# these validate lines automatically create the user error messages stored in @user.errors
# removed presence: true, from the validates :password line b/c already testing for that in
# the line above has_secure_password
  
  def feed
    #preliminary
    Micropost.where("user_id = ?", id)
  end

  private
    
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
  
end # class User
