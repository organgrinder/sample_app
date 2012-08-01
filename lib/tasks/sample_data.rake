namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Example User",
                         email: "example@railstutorial.org",
                         password: "foobar",
                         password_confirmation: "foobar")
    admin.toggle!(:admin)
      

    99.times do |n|
      name  = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password  = "password"
      User.create!(name: name,
                   email: email,
                   password: password,
                   password_confirmation: password)
    end # 99.times
    
    users = User.all(limit: 6)
#---> why is this users instead of @users ?
#---> think i have a little more to digest re @vars vs vars
# and which ones are available to which files
    50.times do
      content = Faker::Lorem.sentence(5)
      users.each { |user| user.microposts.create(content: content) }
    end
    
  end # populate environment
  
end # file