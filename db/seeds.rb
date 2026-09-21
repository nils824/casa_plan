# Demo data. All demo accounts use the password "casaplan-demo".
house = House.find_or_create_by!(name: "Casa Moghegno") do |h|
  h.beds = 6
  h.invitation_code = "moghegno-2026"
end

def demo_user(email, name, role: :member)
  User.find_or_create_by!(email_address: email) do |u|
    u.name = name
    u.role = role
    u.password = "casaplan-demo"
  end
end

manager = demo_user("verwalter@casaplan.ch", "Verwalter", role: :manager)
anna = demo_user("anna@casaplan.ch", "Anna")
ben = demo_user("ben@casaplan.ch", "Ben")
clara = demo_user("clara@casaplan.ch", "Clara")

if house.stays.none?
  # Confirmed stay of Anna
  annas_stay = house.stays.new(user: anna, arrival_on: Date.current + 14, departure_on: Date.current + 21, guests_count: 4)
  annas_stay.save_with_activity(actor: anna, event: "requested")
  annas_stay.confirm_by(manager)

  # Two open requests of Ben and Clara that overlap each other.
  # Only one of them can be confirmed (demo for the concurrency rule).
  house.stays.new(user: ben, arrival_on: Date.current + 30, departure_on: Date.current + 35, guests_count: 2)
       .save_with_activity(actor: ben, event: "requested")
  house.stays.new(user: clara, arrival_on: Date.current + 33, departure_on: Date.current + 37, guests_count: 3,
                  note: "Mit Hund")
       .save_with_activity(actor: clara, event: "requested")
end
