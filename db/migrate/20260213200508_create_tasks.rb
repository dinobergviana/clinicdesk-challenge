class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.string :status, null: false
      t.date :due_date

      t.timestamps
    end

    add_index :tasks, :status
    add_index :tasks, :due_date
  end
end
