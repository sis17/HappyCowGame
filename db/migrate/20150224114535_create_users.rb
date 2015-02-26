class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :email
      t.string :name
      t.string :colour
      t.integer :experience
      t.string :password
      t.string :salt

      t.timestamps
    end
  end
end
