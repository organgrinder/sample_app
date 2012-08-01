class MicropostsController < ApplicationController
  before_filter :signed_in_user, only: [:create, :destroy]
  before_filter :correct_user,   only: :destroy
  
  
  def create
    @micropost = current_user.microposts.build(params[:micropost])
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_path
    else
      @feed_items = []
      render 'static_pages/home'
    end

#---> isn't root_path and static_pages/home the same thing?
# AA not quite, redirect_to is more of a full load, starts anew

# this kind of works, but you lose out on the error messages
# that are are attached to the object sent by the post 
# message form
#      flash[:error] = "Cannot have blank post dummy"
#      redirect_to root_path

#---> question remains - if you keep the object with the
# error messages by saying render 'static_pages/home'
# instead of redirect_to, then why do you lose the
# @feed_items object when you do that render??

#---> also, seems like like the instance var @micropost
# is still available, so why did we lose @feed_items?
# AA oh maybe it's a new @micropost, created right here
# in this file, rather than the one carried over from
# StaticPagesController

#---> want to try to fix this -- feed should show up, even
# after a failed create post attempt

  end # create
  
  def destroy
    @micropost.destroy
    redirect_to root_path
  end
  
  private
    
    def correct_user
      @micropost = current_user.microposts.find_by_id(params[:id])
# use find_by_id instead of find because the latter raises an exception when 
# the micropost doesn’t exist instead of returning nil

# but i don't really like defining @micropost in here, seems un-filter-like

      redirect_to root_path if @micropost.nil?
    end
  
end # MicropostsController