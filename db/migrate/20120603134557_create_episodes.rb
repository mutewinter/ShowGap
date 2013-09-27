class CreateEpisodes < ActiveRecord::Migration
  def change
    create_table :episodes do |t|
      t.string :slug
      t.text :description
      t.string :url

      # Enums
      t.integer :state_cd, default: 10

      # Assocations
      t.integer :show_id

      t.timestamps
    end

    add_index :episodes, :show_id
  end
end
