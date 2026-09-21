house = House.find_or_create_by!(name: "Casa Moghegno") { |h| h.beds = 6 }

manager = User.find_or_create_by!(email_address: "verwalter@casaplan.ch") do |u|
  u.name = "Verwalter"
  u.role = :manager
  u.password = "password"
end

anna = User.find_or_create_by!(email_address: "anna@casaplan.ch") do |u|
  u.name = "Anna"
  u.password = "password"
end

ben = User.find_or_create_by!(email_address: "ben@casaplan.ch") do |u|
  u.name = "Ben"
  u.password = "password"
end

if house.stays.none?
  house.stays.create!(user: anna, arrival_on: Date.current + 14, departure_on: Date.current + 21,
                      guests_count: 4, status: :confirmed, decided_by: manager, decided_at: Time.current)
  house.stays.create!(user: ben, arrival_on: Date.current + 30, departure_on: Date.current + 35,
                      guests_count: 2)
end