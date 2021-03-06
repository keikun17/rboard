task :install => :environment do
  Rake::Task['db:schema:load'].invoke
  # Themes
  Theme.create(:name => "blue", :is_default => true)
  
  # Users
  
  # Anonymous
  anonymous_password = rand(9999) * rand(9999)
  a = User.create!(:login => "anonymous", :password => anonymous_password, :password_confirmation => anonymous_password, :email => "anonymous@rboard.com")
  anonymous_group = Group.create!(:name => "Anonymous", :owner => a)
  anonymous_group.permissions.create!(:can_see_forum => true,
                        :can_see_category => true)
  
  # Administrator
  
  u = User.create!(:login => "admin", :password => "secret", :password_confirmation => "secret", :email => "admin@rboard.com")
  administrator_group = Group.create!(:name => "Administrators", :owner => u) 
  # Admin can do everything!
  permissions = {}
  Permission.column_names.grep(/can/).each do |permission|
    permissions.merge!(permission => true)
  end

  
  # Other miscellaneous groups
  

  registered_group = Group.create!(:name => "Registered Users", :owner => u) 
  registered_group.permissions.create!(:can_see_forum => true,
                        :can_see_category => true,
                        :can_start_new_topics => true,
                        :can_use_signature => true,
                        :can_delete_own_posts => true,
                        :can_edit_own_posts => true,
                        :can_subscribe => true,
                        :can_read_messages => true,
                        :can_see_category => true,
                        :can_see_category => true              
                        )

  groups = [anonymous_group, administrator_group, registered_group]
  
  # Forums
  c = Category.create!(:name => "Welcome")
  c.groups += groups
  groups.each do |group|
    p = group.permissions.find_by_category_id(c.id)
    p.can_see_category 
  end
  
  f = c.forums.create!(:title => "Welcome to rBoard!", :description => "This is just an example forum.")
  f.groups += groups
  
  t = f.topics.build(:subject => "Welcome to rBoard!", :user => u)
  t.posts.build(:text => "Welcome to rBoard, feel free to remove this post, topic and forum.", :user => u)
  t.save!
  puts ""
  puts "***********************"
  puts "Rboard is now installed. The username is admin, and the password is secret."
end