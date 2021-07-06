class Name < ActiveRecord::Base 
    has_many :picks 
    has_many :users, through: :picks 

end 
