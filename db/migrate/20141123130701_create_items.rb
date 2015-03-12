class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.integer :amountAvalible
      t.integer :amountOut
      t.text :description
      t.string :image
      t.text :studentArray

      t.timestamps
    end
  end
end
