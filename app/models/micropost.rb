class Micropost < ActiveRecord::Base
  include MicropostsHelper
  include ActionView::Helpers

  attr_accessible :content
  belongs_to :user
  
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  
  default_scope order: 'microposts.created_at DESC'
#DESC means descending

  before_save { |mp| mp.content = wrap(content) }

end
