class CreateActivities < ActiveRecord::Migration[8.1]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :stay, null: false, foreign_key: true
      t.string :event, null: false
      t.string :summary, null: false

      t.timestamps
    end
  end
end
