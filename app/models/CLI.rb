require "tty-prompt"

class CLI 

    @prompt = TTY::Prompt.new

    @current_user = nil 

    def self.greet 
       puts "Welcome to Kindr!"
    end 


    def self.check_if_have_login_and_create
        check = @prompt.yes?("Do you have a username?")
        if check 
            self.account_login 
        else 
            self.create_new_username
        end 
    end  

    def self.account_login #NEED TO PUT A COUNTER IN HERE TO STOP THE LOOP IF FORGOTTEN
        user_username = @prompt.ask("Enter username")
        user_password = @prompt.mask("Enter password")
        user = User.find_by(username: user_username, password: user_password)
        if !user 
            puts "Not a valid login. Please try again"
            self.account_login 
        else 
            puts "Welcome back #{user.name}! Time to find your baby's name!"
        end 
        @current_user = user 
    end 

    def self.create_new_username 
        username_input = @prompt.ask("Please create a username")
        user = User.find_by(username: username_input)
        if !user 
            user_name = @prompt.ask("What is your name?")
            user_password = @prompt.mask("Create a password")
        new_user = User.create(username: username_input, name: user_name, password: user_password )
        @current_user = new_user
        end 
    end 

  
     
     def self.upload_own_name
        puts "TO BUILD: give us your choice of name"
        puts "TO BUILD: is this a pick or a reject?"
     end
     
     def self.home_menu
        options = [
            {"Random name" => -> do get_random_name end},
            {"Show my matches" => -> do show_matches end},
            {"Upload own name" => -> do upload_own_name end},
            {"Show my Picks" => -> do show_picks(@current_user,"Y") end},
            {"Show my Rejects" => -> do show_picks(@current_user, "N") end},
            {"Log Out" => -> do log_out end},
            {"Delete account" => -> do delete_account end},
        ]
        @prompt.select("here are your options:", options)
     end
#  #------------- SHOW NAMES ---------------------- 
    def self.find_picks(user, yn)
        picks = Pick.where(user_id: user.id, yes_or_no: yn)
        picks_array = picks.map {|pick| pick.name.name}
        
    end

    def self.show_picks(user,yn)
        if yn == "Y"
        puts "Here are all your picks: #{find_picks(user, yn)}"
        else 
        puts "Here are all your rejects: #{find_picks(user, yn)}"
        end 
    end 

    
    def self.find_partner
        partner_username= @prompt.ask("What is your partner's username?")
        @partner_user = User.find_by(username: partner_username)
    end

    def self.show_matches
        find_partner
        matches = find_picks(@current_user, "Y") & find_picks(@partner_user, "Y")
        puts "Here are all your matches: #{matches}"
    end 

    #------------- RANDOM NAME ---------------------- 

    def self.random_name_menu
        # create array of menu choices
        #ask for gender in a menu
        prompt = TTY::Prompt.new
        options = [
            {"Female names" => -> do self.random_name_all("Female") end},
            {"Male names" => -> do self.random_name_all("Male") end},
            {"Genderless names" => -> do self.random_name_all(nil) end},
        ]
        prompt.select("What gender are you looking for?", options)
        # define two methods for our three options
        # call it
    end


    def self.random_name_by_gender(gender)
        if gender
            @random_name = Name.where(gender:gender).sample
        else
            @random_name = Name.all.sample
        end
    end


    def self.random_name_all(gender) 
        random_name_by_gender(gender)
        if Pick.find_by(user_id: @current_user.id, name_id: @random_name.id)
            puts "re-running"
            self.random_name_all(gender)     
        else 
            puts "your name is #{@random_name.name}"
        end 
    end 
    #think of way to tell user that they have run out of names - B/C WILL KEEP LOOPING 

    # like_or_not => 
    def self.like_or_not
        options = [
            {"Yes" => -> do self.pick_name("Y") end},
            {"No" => -> do self.pick_name("N") end},
            {"Take me back to the menu" => -> do self.home_menu end}
        ]
        @prompt.select("Do you like this name?", options)
    end

    #choose name and put in pick folder as yes
    def self.pick_name(yn)
        Pick.create(user_id: @current_user.id,name_id: @random_name.id, yes_or_no: yn)
        get_random_name
    end 


    def self.get_random_name
        random_name_menu
        # random_name_all(gender)
        like_or_not
    end



#---------------------------DELETE ACCOUNT HERE---------------------------------------------
    def self.destroy_account
        puts "TO BUILD: this is where we delete it"
        user_delete_picks = Pick.where(user_id: @current_user.id)
        user_delete_picks.destroy_all
        User.destroy(@current_user.id)
    end

    def self.delete_account
        options = [
            {"Yes, please delete my account" => -> do destroy_account end},
            {"No, please take me back to the menu!" => -> do self.home_menu end}
        ]
        @prompt.select("Are you sure? This will erase all your account info and history.", options)
    end

#---------------------------LOG_OUT METHOD HERE---------------------------------------------

    def self.log_out
        puts "Thank you for using Kindr! See you again soon."
        @current_user = nil
    end
#---------------------------RUN METHOD HERE---------------------------------------------

    def self.methods 
        self.greet
        self.check_if_have_login_and_create
        while @current_user
            self.home_menu
        end
    end 


 end
