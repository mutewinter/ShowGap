class AddDefaultToLinks < ActiveRecord::Migration
  def change
    change_column_default :links, :state, 30
  end
end
