require 'spec_helper'

describe "Static pages" do
  
  subject { page }

  shared_examples_for "all static pages" do
    it { should have_selector('h1', text: heading) }
    it { should have_selector('title', text: full_title(page_title)) }
  end

  describe "Home page" do
    before { visit root_path }
    let(:heading) { 'Sample App' }
    let(:page_title) { '' }
    
    it_should_behave_like "all static pages"
    it { should_not have_selector('title', :text => '| Home') }
    
    describe "for signed-in users" do
      let(:user) { FactoryGirl.create(:user) }
                  
      before do
#        FactoryGirl.create(:micropost, user: user, content: "Hello bitches")
#        FactoryGirl.create(:micropost, user: user, content: "Fuck ass")
# can't put these outside the 'before do'
# believe everything either has to be a 'let' or it has to be inside a 'before { }'

        FactoryGirl.create(:micropost, user: user, content: "Hello bitches microposts")
        sign_in user
        visit root_path
      end
      
      describe "sidebar microposts count singular" do
        it { should have_selector("span.mp", text: '1 micropost') }
        it { should_not have_selector("span.mp", text: 'microposts') }
# labeled the pluralized word with the special class 'mp' just so it can be tested for like this
      end      
            
      describe "sidebar microposts count plural" do
        before do
          FactoryGirl.create(:micropost, user: user, content: "Fuck ass")
          visit root_path
        end
        it { should have_selector("span.mp", text: '2 microposts') }
      end
      
      it "should render the user's feed" do
        FactoryGirl.create(:micropost, user: user, content: "Fuck ass")
        visit root_path
        user.feed.each do |item|
          page.should have_selector("li##{item.id}", text: item.content)
# first '#' is Capybara for an item id--then it's string interp to get the item id we want
        end
      end
        
    end # for signed-in users
    
  end # Home page

  describe "Help page" do
    before { visit help_path }
    let(:heading) { 'Help' }
    let(:page_title) { 'Help' }

    it_should_behave_like "all static pages"
  end

  describe "About page" do
    before { visit about_path }
    let(:heading) { 'About Us' }
    let(:page_title) { 'About Us' }

    it_should_behave_like "all static pages"
  end
  
  describe "Contact page" do
    before { visit contact_path }
    let(:heading) { 'Contact' }
    let(:page_title) { 'Contact' }

    it_should_behave_like "all static pages"
  end
  
  it "should have the right links on the right pages" do
    visit root_path
    click_link "About"
    page.should have_selector 'title', text: full_title('About Us')
    click_link "Help"
    page.should have_selector 'title', text: full_title('Help')
    click_link "Contact"
    page.should have_selector 'title', text: full_title('Contact')
    click_link "Home"
    click_link "Sign up now!"
    page.should have_selector 'title', text: full_title('Sign up')
    click_link "twutter"
    page.should have_selector 'title', text: full_title('')
  end
end