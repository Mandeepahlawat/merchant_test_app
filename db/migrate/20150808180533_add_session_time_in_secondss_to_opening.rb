class AddSessionTimeInSecondssToOpening < ActiveRecord::Migration
  def change
    add_column :openings, :session_time_in_sec, :integer
    add_index  :openings, :session_time_in_sec
  end
end
