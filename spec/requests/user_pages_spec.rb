require 'spec_helper'

describe "User pages" do  
  subject { page }

  describe "signup page" do
    before { visit signup_path }
# say 'before' here so the visit happens before each of the following examples
# it's equivalent to before(:each)
    
    it { should have_selector('h1',    text: 'Sign up') }
    it { should have_selector('title', text: full_title('Sign up')) }
    
  end
  
  describe "another user's profile page" do
    let(:user1) { FactoryGirl.create(:user, name: "new user 1", email: "new@user1.email") }
    let!(:m1) { FactoryGirl.create(:micropost, user: user1, content: "Fuck") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user1, content: "Ass") }
    let(:user2) { FactoryGirl.create(:user, name: "new user 2", email: "new@user2.email") }
    
    before do
      sign_in user2
      visit user_path(user1)
    end
    
    it { should_not have_link('delete') }
    
  end # another user's profile page
  
  describe "profile page" do
    let(:user1) { FactoryGirl.create(:user) }
    let!(:m1) { FactoryGirl.create(:micropost, user: user1, content: "Fuck") }
    let!(:m2) { FactoryGirl.create(:micropost, user: user1, content: "Ass") }
    
    before { visit user_path(user1) }

    it { should have_selector('h1',    text: user1.name) }
    it { should have_selector('title', text: user1.name) }
    
    describe "microposts" do
      it { should have_content(m1.content) }
      it { should have_content(m2.content) }
      it { should have_content(user1.microposts.count) }
    end
    
    describe "pagination" do

      before (:all) { 51.times { FactoryGirl.create(:micropost, user: user1) } }
      before (:each) do
        sign_in user1
        visit user_path(user1)
      end

      it { should have_selector('div.pagination') }

      it "should list each micropost" do
        user1.microposts.paginate(page: 1).each do |mp|
          page.should have_selector('li', text: mp.content)
        end
      end
      
    end # pagination
    
  end # profile page
  
  describe "signup" do
    before { visit signup_path }
    
    let(:submit) { "Create my account" }
    
    describe "with invalid information" do
      it "should not create a user" do
        expect { click_button submit }.not_to change(User, :count)
      end
      
      describe "after submission" do
        before { click_button submit }
        it { should have_selector('title', text: 'Sign up') }
        it { should have_content('error') }
        it { should have_content('Password') }
        it { should have_content('Email') }
        it { should have_content('Name') }
      end
      
    end # with invalid information
    
    describe "with valid information" do
      before do
        fill_in "Name",         with: "Example User"
        fill_in "Email",        with: "user@example.com"
        fill_in "Password",     with: "foobar"
        fill_in "Confirmation", with: "foobar"
      end

      it "should create a user" do
        expect { click_button submit }.to change(User, :count).by(1)
      end
      
      describe "after saving the user" do
        before { click_button submit }
        let(:user) { User.find_by_email('user@example.com') }

        it { should have_selector('title', text: user.name) }
        it { should have_selector('div.alert.alert-success', text: 'Welcome') }
        it { should have_link('Sign out') }
      end
      
    end # with valid information
    
  end # signup
  
  describe "edit" do
    let(:user) { FactoryGirl.create(:user) }
    before do
      sign_in user
      visit edit_user_path(user) 
    end
    
    describe "page" do
      it { should have_selector('title', text: 'Edit') }
      it { should have_selector('h1', text: 'Update your profile') }
      it { should have_link('change', href: 'http://gravatar.com/emails') }
    end
    
    describe "with invalid information" do
      before { click_button "Save changes" }
      
      it { should have_content('error') }
    end
    
    describe "with valid information" do
      let(:new_name) { "New Name" }
      let(:new_email) { "new@example.com" }
      before do
        fill_in "Name",             with: new_name
        fill_in "Email",            with: new_email
        fill_in "Password",         with: user.password
        fill_in "Confirmation", with: user.password
        click_button "Save changes"
# this doesn't have to actually match the button text, it just has to be contained in 
# the button text i.e. it also works to just have "changes" here
      end
        
      it { should have_selector('title', text: new_name) }
      it { should have_selector('div.alert.alert-success') }
      it { should have_link('Sign out', href: signout_path) }
      specify { user.reload.name.should  == new_name }      
      specify { user.reload.email.should == new_email }

# This reloads the user variable from the test database using 
# user.reload, and then verifies that the user’s new name and 
# email match the new values.
      
    end # with valid information
    
  end # edit
  
  describe "index" do

    let(:user) { FactoryGirl.create(:user) }

    before(:all) { 30.times { FactoryGirl.create(:user) } }
    after(:all)  { User.delete_all }

    before(:each) do
      sign_in user
      visit users_path
    end

    it { should have_selector('title', text: 'All users') }
    it { should have_selector('h1',    text: 'All users') }

    describe "pagination" do

      it { should have_selector('div.pagination') }

      it "should list each user" do
        User.paginate(page: 1).each do |user|
          page.should have_selector('li', text: user.name)
        end
      end
      
    end # pagination
    
    describe "delete links" do

          it { should_not have_link('delete') }

          describe "as an admin user" do
            let(:admin) { FactoryGirl.create(:admin) }
            before do
              sign_in admin
              visit users_path
            end

            it { should have_link('delete', href: user_path(User.first)) }
            it "should be able to delete another user" do
              expect { click_link('delete') }.to change(User, :count).by(-1)
            end
            it { should_not have_link('delete', href: user_path(admin)) }
          end
      
    end # delete links
    
  end # index
  
end # User pages
