require 'spec_helper'

describe Relationship do
  
  let(:follower1) { FactoryGirl.create(:user) }
  let(:followed1) { FactoryGirl.create(:user) }
  let(:relationship1) { follower1.relationships.build(followed_id: followed1.id) }
# could use @follower, @followed etc instead of 'let' here
  
  subject { relationship1 }
  
  it { should be_valid }
  
  describe "accessible attributes" do 

    it "should not allow access to follower_id" do
      expect do
        Relationship.new(follower_id: follower1.id)
      end.should raise_error(ActiveModel::MassAssignmentSecurity::Error)
    end
    
  end # "accessible attributes"
  
  describe "follower methods" do
    it { should respond_to(:follower) }
    it { should respond_to(:followed) }
    its(:follower) { should == follower1 }
    its(:followed) { should == followed1 }
  end
  
  describe "when followed id is not present" do
    before { relationship1.followed_id = nil }
    it { should_not be_valid }
  end

  describe "when follower id is not present" do
    before { relationship1.follower_id = nil }
    it { should_not be_valid }
  end
  
end # Relationship
