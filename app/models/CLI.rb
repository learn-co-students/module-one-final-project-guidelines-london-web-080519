require "tty-prompt"
require  "colorize"

class CLI 

    @prompt = TTY::Prompt.new
    @current_user = nil 

    def self.kindr 
        font = TTY::Font.new(:standard)
        puts font.write("kindr").yellow
     end 


    def self.greet 
       puts "Welcome to Kindr!".light_green.bold
    end 


    def self.check_if_have_login_and_create
        options = [
            {"Yes" => -> do self.account_login  end},
            {"No" => -> do self.create_new_username end},
        ]
        @prompt.select("\nDo you have an account with Kindr?", options)
    end
    

    def self.account_login 
        user_username = @prompt.ask("Enter username: ")
        user_password = @prompt.mask("Enter password: ")
        user = User.find_by(username: user_username, password: user_password)
        if !user 
            options = [
                {"Try again" => -> do account_login  end},
                {"Create new account" => -> do create_new_username end}
            ]
            @prompt.select("Not a valid login. Please try again or create new account".light_red, options)
        else 
            system('clear')
            puts "Welcome back #{user.name}! Time to find your baby's name!"
            @current_user = user 
       end 
    end 

    def self.create_new_username 
        user_name = @prompt.ask("What is your name?")
        username_input = @prompt.ask("Please create a username: ")
        user = User.find_by(username: username_input)
        if !user 
            check_password_input("Enter a password: ")
            @current_user = User.create(username: username_input, name: user_name, password: @new_password )
        else
            options = [
            {"Try again" => -> do create_new_username end},
            {"Log in with existing account" => -> do account_login end}, 
        ]
        @prompt.select("This username is already taken! Please try again or log in with an existing account.".light_red, options)
        end 
    end 

    def self.check_password_input(message = nil)
        @new_password = @prompt.mask(message)
        new_password2 = @prompt.mask("Please enter it again: ")
        if @new_password != new_password2 
            options = [
                {"Try again" => -> do self.check_password_input(message) end}, 
                {"Take me back to the home menu" => -> do home_menu end}
            ]
            @prompt.select("Passwords do not match.  Please try again or return to homepage.".light_red, options)
        end 
    end 


#  #------------- HOME MENU ----------------------     


    def self.home_menu
        sleep(1.1)
        system('clear')
        options = [
            {"Random name" => -> do get_random_name end},
            {"Upload own name" => -> do upload_own_name end},
            {"Show my Matches" => -> do show_matches end},
            {"Show my Picks" => -> do show_picks_runner(@current_user,"Y") end},
            {"Show my Rejects" => -> do show_picks_runner(@current_user, "N") end},
            {"Log Out" => -> do log_out end},
            {"Account Settings" => -> do account_settings end},
        ]
        @prompt.select("Here are your options: ", options, per_page: 7)
    end


#  #------------- SHOW NAMES ---------------------- 


    def self.show_picks_runner(user, yn)
        puts "\n"
        show_picks(user, yn)
        choose_change_picks(yn)
    end

    def self.show_picks(user,yn)
        if yn == "Y"
            puts "Here are all your Picks: "        
        else 
            puts "Here are all your Rejects: "
        end 
        find_picks(user, yn).each {|name| puts name}
    end 


    def self.find_picks(user, yn)
        picks = Pick.where(user_id: user.id, yes_or_no: yn)
        picks_array = picks.map {|pick| pick.name.name}.sort
    end

    def self.choose_change_picks(yn)
        options = [
            {"Yes" => -> do update_pick(yn) end},
            {"No" => -> do home_menu end},
        ]
        @prompt.select("\nDo you want to change any names?", options)
    end 


    def self.already_picked(name)
        user_picks = find_picks(@current_user, "Y") + find_picks(@current_user, "N")
        user_picks.include?(name)
    end

    def self.update_pick(yn)
        update_name = @prompt.ask("Which name do you want to update?").strip.to_s.titleize
        if already_picked(update_name)
            update_name_id = Name.find_by(name: update_name)
            update_new_name_pick(update_name_id, yn)
        else 
            puts "Can't find that name!".light_red
            update_pick(yn)
        end 

    end 
    

    
    def self.find_partner
        puts "\n"
        partner_username= @prompt.ask("What is your partner's username?")
        if User.find_by(username: partner_username) 
            @partner_user = User.find_by(username: partner_username)
        else 
            options = [
                {"Try again" => -> do find_partner end},
                {"Go back to home menu" => -> do home_menu end}
            ]
            @prompt.select("Invalid username.  Please try again or return to home menu".light_red, options)
        end 
    end


    def self.show_matches
        find_partner
        matches = find_picks(@current_user, "Y") & find_picks(@partner_user, "Y")
        if matches.empty?
            puts "Sorry, you and your partner do not yet have any Matches."
        else 
            puts "\nHere are all your Matches: "
            matches.each {|name| puts name.yellow.bold}.sort
        end 
        options = [
            {"Let's go!" => -> do home_menu  end},
        ]
        @prompt.select("\nBack to home menu?", options, per_page: 7)
    
    end  


    #------------- RANDOM NAME ---------------------- 

    def self.random_name_menu 
        system('clear')
        options = [
            {"Female names" => -> do random_name_all("Female") end},
            {"Male names" => -> do random_name_all("Male") end},
            {"All names" => -> do random_name_all(nil) end},
            {"Take me back to the menu" => -> do self.home_menu end}
        ]
        @prompt.select("What gender are you looking for?", options)
    end

    def self.random_name_all(gender) 
        random_name_by_gender(gender)
        if Pick.find_by(user_id: @current_user.id, name_id: @random_name.id)
            random_name_all(gender)     
        else 
            system('clear')
            puts "Your name is " + @random_name.name.yellow.bold
            like_or_not
        end 
    end 


    def self.random_name_by_gender(gender)
        if gender
            @random_name = Name.where(gender:gender).sample
        else
            @random_name = Name.all.sample
        end
    end


    def self.no_names_left?
        @current_user.picks.count >= Name.all.count 
    end 


    def self.like_or_not
        options = [
            {"Yes" => -> do self.pick_name("Y") end},
            {"No" => -> do self.pick_name("N") end},
            {"Take me back to the menu" => -> do self.home_menu end}
        ]
        @prompt.select("\nDo you like this name?", options)
    end

    def self.pick_name(yn)
        Pick.create(user_id: @current_user.id,name_id: @random_name.id, yes_or_no: yn)
        get_random_name
    end 



    def self.get_random_name
        if no_names_left?
        puts "\nSorry, there are no more names in the database.  Try uploading your own."
        upload_own_name
        else 
        random_name_menu
        end 
    end

#------------------------------UPLOAD OWN NAME---------------------------------------------

    def self.upload_own_name
        puts "\n"
        @user_own_name = @prompt.ask("Give us your choice of name: ").strip.gsub('"', '').titleize
        options = [
                {"Female" => -> do new_name_and_pick("Female") end},
                {"Male" => -> do new_name_and_pick("Male") end},
            ]
            @prompt.select("What is the gender of this name?", options)

        end 
        
    def self.new_name_and_pick(gender)
        new_name = Name.find_or_create_by(name: @user_own_name.to_s, gender: gender)
        if find_picks(@current_user, "N").include?(new_name.name)
            puts "This name is already in your rejects!"
            options = [
                {"Yes" => -> do update_new_name_pick(new_name, "N") end},
                {"No" => -> do home_menu end},
            ]
            @prompt.select("Do you want to change this to a pick?", options)
        else
            Pick.find_or_create_by(user_id: @current_user.id,name_id: new_name.id, yes_or_no: "Y")
            puts "This name has been included in your picks!"
        end
    end 


    def self.update_new_name_pick(name, yn)
        update_this_pick = Pick.where(user_id: @current_user.id, name_id: name.id)
        if yn == "Y"
            update_this_pick.update(yes_or_no: "N")
        else
            update_this_pick.update(yes_or_no: "Y")
        end
        puts "Pick has been updated!"
    end 

#---------------------------ACCOUNT SETTINGS HERE---------------------------------------------
    
def self.account_settings 
    options = [
        {"Update password" => -> do update_password end},
        {"Delete account" => -> do self.delete_account end}, 
        {"Take me back to the home menu" => -> do home_menu end}
    ]
    @prompt.select("\nWhat would you like to do?", options)
end

def self.update_password
    verify_password
    if check_password_input("Enter a new password: ")
        @current_user.update(password: @new_password) 
    end
end 

def self.verify_password
    current_password = @prompt.mask("Enter your current password: ")
    if !User.find_by(id: @current_user.id, password: current_password)
        options = [
            {"Try again" => -> do self.verify_password end}, 
            {"Take me back to the home menu" => -> do home_menu end}
        ]
        @prompt.select("Current password is incorrect.  Please enter it again or return to homepage.".light_red, options)
    end 
end 


def self.destroy_account
    verify_password
        user_delete_picks = Pick.where(user_id: @current_user.id)
        user_delete_picks.destroy_all
        User.destroy(@current_user.id)
        puts "Your account has been succesfully deleted."
        log_out
    end

    def self.delete_account
        options = [
            {"Yes, please delete my account" => -> do destroy_account end},
            {"No, please take me back to the menu!" => -> do self.home_menu end}
        ]
        @prompt.select("Are you sure? This will erase all your account info and history.".light_red, options)
    end



#---------------------------LOG_OUT METHOD HERE---------------------------------------------

    def self.log_out
        puts "\nThank you for using Kindr! See you again soon."
        font = TTY::Font.new(:standard)
        puts font.write("Goodbye!").yellow
        @current_user = nil
    end

#---------------------------RUN METHOD HERE---------------------------------------------

    def self.methods 
        system('clear')
        kindr
        self.greet
        self.check_if_have_login_and_create
        while @current_user
            self.home_menu
        end
    end 

 



end