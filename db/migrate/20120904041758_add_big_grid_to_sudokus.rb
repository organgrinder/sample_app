class AddBigGridToSudokus < ActiveRecord::Migration
  def change
    add_column :sudokus, :big_grid, :text
  end
end
