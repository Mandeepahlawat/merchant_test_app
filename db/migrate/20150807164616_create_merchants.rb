class CreateMerchants < ActiveRecord::Migration
  def change
    create_table :merchants do |t|
      t.string :name
      t.string :email
      t.integer :status, default: 1
      t.text :about
      t.integer :gender, default: 0
      t.float :price
      t.integer :review_count
      t.float :avg_rating

      t.timestamps null: false
    end
    add_index :merchants, :price
    add_index :merchants, :avg_rating
    add_index :merchants, :email, unique: true
  end
end
