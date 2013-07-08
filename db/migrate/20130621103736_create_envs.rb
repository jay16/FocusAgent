class CreateEnvs < ActiveRecord::Migration
  def change
    create_table :envs do |t|
      t.string :idstr
      t.string :issue
      t.integer :pid
      t.integer :port
      t.string :rails
      t.string :ruby
      t.string :gem
      t.string :user
      t.string :time_zone
      t.boolean :selinux
      t.text :iptables
      t.float :volume
      t.float :used
      t.boolean :online

      t.timestamps
    end
  end
end
