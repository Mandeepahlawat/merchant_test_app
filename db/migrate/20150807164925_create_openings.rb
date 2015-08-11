class CreateOpenings < ActiveRecord::Migration
  def change
    create_table :openings do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.integer :status, default: 0
      t.integer :merchant_id
      t.timestamps null: false
    end
    add_index :openings, :merchant_id
    add_foreign_key :openings, :merchants
  end
end
