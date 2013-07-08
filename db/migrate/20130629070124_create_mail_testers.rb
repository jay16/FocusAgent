class CreateMailTesters < ActiveRecord::Migration
  def change
    create_table :mail_tests do |t|
      t.integer :campaign_id
      t.string :domain
      t.string :eml_file
      t.string :email
      t.string :mqpath
      t.text :log_cm

      t.timestamps
    end
  end
end
