class ChangeShowNameToTitle < ActiveRecord::Migration
  def up
    rename_column :shows, :name, :title
  end

  def down
    rename_column :shows, :title, :name
  end
end
