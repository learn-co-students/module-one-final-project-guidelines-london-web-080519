class User < ActiveRecord::Base 
    has_many :picks 
    has_many :names, through: :picks 

end 
