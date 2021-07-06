require_relative "../app/models/name.rb"

# User.create(name: "Angie" , username: "angieshin", password:"abc123")
# User.create(name: "Tegan", username: "tegansims", password: "123456")
# User.create(name: "Oli", username:"oliburt", password:"123abc")
# User.create(name: "George" , username:"georgekirby", password: "654321")


# 100.times do 
#     girl_name = Faker::Name.unique.female_first_name 
#     Name.create(name: girl_name, gender: "Female")
#     end

# 100.times do 
#     boy_name = Faker::Name.unique.male_first_name 
#     Name.create(name: boy_name, gender: "Male")
#     end
    

    # Pick.create(user_id: 15, name_id: 405, comment: "great", rating: 4, yes_or_no: "Y")
    # Pick.create(user_id: 15, name_id: 409, comment: "fab", rating: 4, yes_or_no: "Y")
    # Pick.create(user_id: 15, name_id: 510, comment: "wonderful", rating: 4, yes_or_no: "Y")
    # Pick.create(user_id: 15, name_id: 488, comment: "ew", rating: 4, yes_or_no: "N")

    # Pick.create(user_id: 14, name_id: 405, comment: "great", rating: 4, yes_or_no: "Y")
    # Pick.create(user_id: 14, name_id: 409, comment: "fab", rating: 4, yes_or_no: "Y")
    # Pick.create(user_id: 14, name_id: 506, comment: "wonderful", rating: 4, yes_or_no: "Y")
    # Pick.create(user_id: 14, name_id: 508, comment: "ew", rating: 4, yes_or_no: "N")


    Name.all.each do |name|
        Pick.create(user_id: 31, name_id: name.id, comment: "meh", rating: 3, yes_or_no: "N")
    end 