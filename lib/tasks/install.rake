task :install => ['db:create:all', :environment] do
  Rake::Task["db:schema:load"].invoke
  Theme.create(:name => "blue", :is_default => true)
  # Because position is the primary key, you cannot set it normally
  UserLevel.connection.execute("INSERT INTO user_levels (name, position) VALUES ('User', '1')")
  UserLevel.connection.execute("INSERT INTO user_levels (name, position) VALUES ('Moderator', '2')")
  UserLevel.connection.execute("INSERT INTO user_levels (name, position) VALUES ('Administrator', '3')")
  u = User.create(:login => "admin", :password => "secret", :password_confirmation => "secret", :email => "admin@rboard.com", :user_level => UserLevel.find_by_name("Administrator"))
  f = Forum.create(:title => "Welcome to rBoard!", :description => "This is just an example forum.", :is_visible_to => UserLevel.find_by_name("Administrator"), :topics_created_by => UserLevel.find_by_name("Administrator"))
  t = f.topics.create(:subject => "Welcome to rBoard!", :user => u)
  t.posts.create(:text => "Welcome to rBoard, feel free to remove this post, topic and forum.")
  
  puts "Rboard is now installed. The username is admin, and the password is secret."
end