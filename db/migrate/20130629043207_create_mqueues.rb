class CreateMqueues < ActiveRecord::Migration
  def change
    create_table :mqueues do |t|
      t.string :mqpath
      t.string :domain
      t.integer :index
      t.boolean :is_valid

      t.timestamps
    end
  end
end
