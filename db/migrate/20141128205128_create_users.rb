class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :userID
      t.text :productArray

      t.timestamps
    end
  end
end
