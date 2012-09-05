class CreateSudokus < ActiveRecord::Migration
  create_table :sudokus do |t|
    t.text :content

    t.timestamps
  end
end
