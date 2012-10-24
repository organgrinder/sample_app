FactoryGirl.define do
  factory :user do
    sequence(:name)  { |n| "Person #{n}" }
    sequence(:email) { |n| "person_#{n}@example.com" }
    password "foobar"
    password_confirmation "foobar"
    
    factory :admin do
      admin true
    end
    
  end # factory :user
  
  factory :relationship do
    follower_id   1
    followed_id   1
  end
  
  factory :micropost do
    content "Hello bitches"
    user
  end
  
end # FactoryGirl.define