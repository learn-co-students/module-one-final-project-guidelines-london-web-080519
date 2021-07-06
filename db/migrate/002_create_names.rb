class CreateNames < ActiveRecord::Migration[4.2]

    def change 
        create_table :names do |t|
            t.string :name 
            t.string :gender 
        end 
    end 
end
