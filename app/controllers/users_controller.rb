class UsersController < ApplicationController

  def show 
    @userToShow = User.find(params[:id])
    
# I really want to change the rest of these @users to things more descriptive
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      flash[:success] = "Welcome to the Sample App!"
#flash is a magic word
#QQ: why does this not persist - how does user_path, which is show user, know 
#after a reload not to redo the flash message?
#AA: b/c nothing gets saved between reloads [correction: not reloads, but *redirects*] 
#except the database -- 
#every reload [*redirect*] is like starting the program anew, that's why we can 
#e.g. keep saying things like @user=User.new above without the prog 
#getting confused - only one of these is called each time

#also, success class styling is part of Bootstrap

      redirect_to @user
#can we say redirect_to user_path here instead?
    else
      render 'new'
#error messages get displayed here b/c render 'new' doesn't reload the page or
#restart anything - the user object with error messages still exists
    end
  end
end