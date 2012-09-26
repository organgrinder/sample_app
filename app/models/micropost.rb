class Micropost < ActiveRecord::Base
  include MicropostsHelper
  include ActionView::Helpers

  attr_accessible :content
  belongs_to :user
  
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  
  default_scope order: 'microposts.created_at DESC'
#DESC means descending

  def self.from_users_followed_by(user)
    
    followed_user_ids = "SELECT followed_id FROM relationships
                         WHERE follower_id = :user_id"
    where("user_id IN (#{followed_user_ids}) OR user_id = :user_id",
          user_id: user.id)
                         
    # below is slow and was replaced with the above -
    # is slow b/c it looks through followed_user_ids array for every 
    # micropost in the database
    
    # above is faster b/c it pushes the set/subset logic to the database
    # which is more efficient

    # =>   followed_user_ids = user.followed_user_ids
  
    # user.followed_user_ids is array; same array you would get from
    # (user.followed_users.map { |i| i.to_s }).join(', ') or 
    # user.followed_users.map(&:to_s).join(', ')
    # technically should be a string for use in the query below, but 
    # the ? takes care of that and converts it automatically
    
    # =>    where("user_id IN (?) OR user_id = ?", followed_user_ids, user)

    # Rails causes "user" above to work like "user_id"
    
  end

  before_save { |mp| mp.content = wrap(content) }
  
end
