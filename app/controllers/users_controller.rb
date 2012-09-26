class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update, :destroy, 
                :following, :followers]
  before_filter :correct_user,    only: [:edit, :update]
  before_filter :admin_user,      only: :destroy
  before_filter :not_signed_in_user, only: [:new, :create]

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.followed_users.paginate(page: params[:page])
    render 'show_follow'
  end
  
  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
    # show_follow is a full view, not a partial
  end

  def show 
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def method_name
    new
    @user
  end

  def new
    @user = User.new
# must be @user, nothing else, b/c it's used in a form_for

  end
  
  def create
    @user = User.new(params[:user])
# must be @user, nothing else, b/c otherwise the form_for that gets called
# in the else clause via 'render 'new'' gets screwed up
#---> not sure why

    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
      
      redirect_to @user
# cannot say redirect_to user_path here instead--b/c user_path is meaningless
# we could say redirect_to user_path(@user)

    else
      render 'new'
    end

  end # create
  
  def edit
#    @user = User.find(params[:id])
# no longer need this b/c it happens inside correct_user, called every time edit or update is called
  end # edit
  
  def update
    if @user.update_attributes(params[:user])
# this line sends a hash -- :user is itself a hash within the params hash 
      flash[:success] = "Profile updated!"
      sign_in @user
# believe we need to sign in the user again b/c update_attributes invokes a save 
# (which we know resets the remember token)
      redirect_to @user
    else
      render 'edit'
    end
    
  end # update
  
  def index
#    flash[:success] = "Remote IP is: #{request.remote_ip}" if request.get?
# request.get? tells whether the request made was a GET request
    @users = User.paginate(page: params[:page])
# instance vars like @users link actions and views
# when defined here, they are automatically available in the index.html.erb view
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed"
    redirect_to users_path
  end
  
  private
  
    def correct_user
      @user = User.find(params[:id])
      redirect_to root_path unless current_user?(@user)
# parens not necessary around (root_path)
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
    
    def not_signed_in_user
      redirect_to(root_path, notice: "Naughty, naughty!") if signed_in?
    end
  
end # Class UsersController