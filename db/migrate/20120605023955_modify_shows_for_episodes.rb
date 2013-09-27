class ModifyShowsForEpisodes < ActiveRecord::Migration
  def up
    remove_column :shows, :live
    add_column :shows, :subdomain, :string
  end

  def down
    add_column :shows, :live, :boolean
    remove_column :shows, :subdomain
  end
end
