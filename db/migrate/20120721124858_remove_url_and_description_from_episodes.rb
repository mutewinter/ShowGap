class RemoveUrlAndDescriptionFromEpisodes < ActiveRecord::Migration
  def up
    remove_column :episodes, :description
    remove_column :episodes, :url
  end

  def down
    add_column :episodes, :description
    add_column :episodes, :url
  end
end
