class CreateMerchantsSpecializations < ActiveRecord::Migration
  def change
    create_table :merchants_specializations do |t|
      t.integer :merchant_id
      t.integer :specialization_id
    end
    add_index :merchants_specializations, :merchant_id
    add_index :merchants_specializations, :specialization_id
    add_index :merchants_specializations, [:merchant_id, :specialization_id], unique: true
    add_foreign_key :merchants_specializations, :merchants
    add_foreign_key :merchants_specializations, :specializations
  end
end
