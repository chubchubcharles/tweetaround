class User < ActiveRecord::Base
	#to associate a user with MANY posts
	has_many :microposts
end
