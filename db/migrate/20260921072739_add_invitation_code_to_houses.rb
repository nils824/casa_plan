class AddInvitationCodeToHouses < ActiveRecord::Migration[8.1]
  def change
    add_column :houses, :invitation_code, :string
  end
end
