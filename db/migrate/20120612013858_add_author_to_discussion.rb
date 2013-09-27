class AddAuthorToDiscussion < ActiveRecord::Migration
  def change
    add_column :discussions, :author_id, :integer
    add_index :discussions, :author_id
  end
end
