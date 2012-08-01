require 'spec_helper'

describe "MicropostPages" do

  subject { page }
  
  let(:user2) { FactoryGirl.create(:user) }
  before { sign_in user2 }
  
  describe "micropost creation" do
    before { visit root_path }
    
    describe "with invalid information" do
      
      it "should not create a micropost" do
        expect { click_button "Post" }.should_not change(Micropost, :count)
      end
      
      describe "error messages" do
        before { click_button "Post" }
        it { should have_content('error') }
      end
      
    end # with invalid information
    
    describe "with valid information" do
      
      before { fill_in 'micropost_content', with: "Ass Bitches" }
      it "should create a micropost" do
        expect { click_button "Post" }.should change(Micropost, :count).by(1)
      end
      
    end # with valid information
    
  end # micropost creation
  
  describe "micropost destruction" do
    before { FactoryGirl.create(:micropost, user: user2) }
    
    describe "as correct user" do
      before { visit root_path }
      
      it "should delete a micropost" do
        expect { click_link "delete" }.should change(Micropost, :count).by(-1)
      end
      
    end # as correct user
    
  end # micropost destruction
  
end # MicropostPages
