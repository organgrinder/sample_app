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
# has_secure_password automatically creates "validates"-type tests for password_digest field in the db

  has_many :microposts, dependent: :destroy
# b/c we're in the User class, this line tells Rails that it can 
# look up a User's microposts by the 'user_id' field in the 'microposts' table 

  has_many :relationships, foreign_key: "follower_id", dependent: :destroy
# b/c there is no 'follower_id' class, we need this line to tell Rails
# to look up a User's relationships by the 'follower_id' field in the 
# 'relationships' table

  has_many :followed_users, through: :relationships, source: :followed
# 'source: :followed' tells Rails that followed_users are found in the
# 'followed_id' column of the 'relationships' table, rather than the
# 'followed_users_id' column, which it would otherwise assume
# (Rails already knows to look up users in the relationships table 
# by the 'follower_id' field b/c of the previous line)

  has_many :reverse_relationships,  foreign_key: "followed_id",
                                    class_name: "Relationship",
                                    dependent: :destroy
                                    
  has_many :followers, through: :reverse_relationships, source: :follower
  
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
  
  def following?(other_user)
    relationships.find_by_followed_id(other_user.id)
  end
  
  def follow!(other_user)
    relationships.create!(followed_id: other_user.id)
  end
  
  def unfollow!(other_user)
    relationships.find_by_followed_id(other_user.id).destroy
  end

  private
    
    def create_remember_token
      self.remember_token = SecureRandom.urlsafe_base64
    end
  
end # class User
