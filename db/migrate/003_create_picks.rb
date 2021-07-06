class CreatePicks < ActiveRecord::Migration[4.2]

    def change 
        create_table :picks do |t|
            t.integer :user_id
            t.integer :name_id 
            t.string :comment 
            t.integer :rating 
            t.string :yes_or_no
        end 
    end
end
