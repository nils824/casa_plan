class CreateStays < ActiveRecord::Migration[8.1]
  def change
    create_table :stays do |t|
      t.references :house, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :decided_by, foreign_key: { to_table: :users }
      t.date :arrival_on, null: false
      t.date :departure_on, null: false
      t.integer :guests_count, null: false
      t.string :status, null: false, default: "requested"
      t.text :note
      t.text :rejection_reason
      t.datetime :decided_at
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :stays, [:house_id, :status, :arrival_on]
  end
end