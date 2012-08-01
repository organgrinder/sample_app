require 'spec_helper'

describe "Authentication" do

  subject { page }
  
  describe "signin page" do
    before { visit signin_path }
    
    it { should have_selector('h1', text: 'Sign in') }
    it { should have_selector('title', text: 'Sign in') }
  end
  
  describe "signin" do
    before { visit signin_path }
    
    describe "with invalid information" do
      before { click_button "Sign in" }
      
      it { should have_selector('title', text: 'Sign in') }
      it { should have_selector('div.alert.alert-error', text: 'Invalid') }
      
      describe "after visiting another page" do
        before { click_link "Home" }
        it { should_not have_selector('div.alert.alert-error') }
      end
      
    end # with invalid information
    
    describe "with valid information" do
      let(:user) { FactoryGirl.create(:user) }
      before { sign_in user }

#replaced the below with the above helper
#      before do
#        fill_in "Email", with: user.email
#        fill_in "Password", with: user.password
#        click_button "Sign in" 
#      end
      
      it { should have_selector('title', text: user.name) }
      
      it { should have_link('Users',    href: users_path) }
      it { should have_link('Profile',  href: user_path(user)) }
      it { should have_link('Settings', href: edit_user_path(user)) }
      it { should have_link('Sign out', href: signout_path) }
      
      it { should_not have_link('Sign in', href: signin_path) }
      
      describe "submitting unnecssary actions to User controller" do
        
        describe "submitting NEW action to User controller" do
          before { get new_user_path }
          specify { response.should redirect_to(root_path) }
        end
        
        describe "submitting CREATE action to User controller" do
          before { post users_path }
          specify { response.should redirect_to(root_path) }
        end

      end # submitting unnecessary actions to User controller
    
      describe "followed by signout" do
        before { click_link 'Sign out' }
        it { should have_link('Sign in') }
        it { should_not have_link('Profile') }
        it { should_not have_link('Settings') }
      end
    
    end # with valid information
      
  end # signin
  
  describe "authorization" do
    
    describe "for non-signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
      
      describe "when attempting to visit a protected page" do
        before do
          visit edit_user_path(user)
          fill_in "Email", with: user.email
          fill_in "Password", with: user.password
          click_button "Sign in"
        end
        
        describe "after signing in" do

          it "should friendly forward/render the desired protected page" do
            page { should have_selector('title', text: 'Edit user') }
          end
          
          describe "after signing in again" do
            before do
              visit signin_path
              fill_in "Email",    with: user.email
              fill_in "Password", with: user.password
              click_button "Sign in"
            end
            
            describe "should not friendly forward again" do
              it { should_not have_selector('title', text: 'Edit user') }
              it { should have_selector('h1', text: user.name) }
            end
            
          end # after signing in again
            
        end # after signing in
        
      end # when attempting to visit a protected page
      
      describe "in the Users controller" do
        
        describe "visiting the edit page" do
          before { visit edit_user_path(user) }
          it { should have_selector('title', text: 'Sign in') }
        end
        
        describe "submitting to the update action" do
          before { put user_path(user) }
          specify { response.should redirect_to(signin_path) }
        end
        
        describe "when visiting the users index" do
          before { visit users_path }
          it { should have_selector('title', text: 'Sign in') }
        end
        
      end # in the Users controller
      
      describe "in the Microposts controller" do
        
        describe "submitting to the create action" do
          before { post microposts_path }
# micropost[S]_path
          specify { response.should redirect_to(signin_path) }
        end
        
        describe "submitting to the destroy action" do
          before { delete micropost_path(FactoryGirl.create(:micropost)) }
#micropost[NO S]_path(micropost)
          specify { response.should redirect_to(signin_path) }
        end
        
      end # in the Microposts controller
      
    end # for non-signed-in users
    
    describe "as wrong user" do
      let(:user) { FactoryGirl.create(:user) }
      let(:wrong_user) { FactoryGirl.create(:user, email: "wrong@example.com") }
      before { sign_in user }
      
      describe "visiting Users#edit page" do
        before { visit edit_user_path(wrong_user) }
        it { should_not have_selector('title', text: 'Edit user') }
      end
      
      describe "submitting a PUT request to the Users#update action" do
        before { put user_path(wrong_user) }
        specify { response.should redirect_to(root_path) } 
      end
      
    end # as wrong user
    
    describe "as non-admin user" do
      
      let(:user) { FactoryGirl.create(:user) }
      let(:non_admin) { FactoryGirl.create(:user) }
      
      before { sign_in non_admin }
      
      describe "submitting a DELETE request to the Users#destroy action" do
        before { delete user_path(user) }
        specify { response.should redirect_to(root_path) }
      end
      
    end # as non-admin user
    
  end # authorization
  
end # Authentication
