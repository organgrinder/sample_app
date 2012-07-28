class UsersController < ApplicationController
  before_filter :signed_in_user,  only: [:index, :edit, :update]
  before_filter :correct_user,    only: [:edit, :update]
  before_filter :admin_user,      only: :destroy

  def show 
    @userToShow = User.find(params[:id])
#---> can I change the rest of these @users to things more descriptive?
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"

      redirect_to @user
#---> can we say redirect_to user_path here instead?
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
# ---> why do we need to sign in the user again?
      redirect_to @user
    else
      render 'edit'
    end
    
  end # update
  
  def index
    @users = User.paginate(page: params[:page])
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User destroyed"
    redirect_to users_path
  end
  
  private
  
    def signed_in_user
      unless signed_in?
        store_location
        redirect_to signin_path, notice: "Please sign in." 
      end
    end
    
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
# ---> are the parens necessary around (root_path) ?
    end
    
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
  
end # Class UsersController