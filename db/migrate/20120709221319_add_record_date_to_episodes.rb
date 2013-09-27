class AddRecordDateToEpisodes < ActiveRecord::Migration
  def change
    add_column :episodes, :record_date, :datetime
  end
end
