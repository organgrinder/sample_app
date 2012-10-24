class RelationshipsController < ApplicationController
  before_filter :signed_in_user
  # this is in helpers/sessions_helper
  # apparently, this does not need to be in any special place, rails can find it
  
  def create
    @user = User.find(params[:relationship][:followed_id])
    # in the params hash under :relationship, is a hash with 1 entry: {"followed_id" => "9"}
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end

    # this works b/c Ajax uses js to implement the action
    # causes rails to call a JavaScript Embedded Ruby file create.js.erb
    # 'redirect_to @user' reloads the page the user is already on - seems redundant
  end 
  
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      # respond_to refers to the action - create or destroy
      # and Rails automatically translates this into a .erb file
      # so format.js will usually call destroy.js.erb
      format.html { redirect_to @user }
      format.js
    end
  end
  
end
