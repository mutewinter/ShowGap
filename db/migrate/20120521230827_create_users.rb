class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :provider
      t.string :uid

      t.string :name
      t.string :nickname
      t.string :description
      t.string :image
      t.string :website
      t.string :location

      t.timestamps
    end
  end
end
