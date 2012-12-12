class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.string :name
      t.string :expansion
      t.float :price

      t.timestamps
    end
  end
end
