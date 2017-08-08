# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

HOCKEY_POSITION = [ "Forward", "Defense", "Goalie" ]
HOCKEY_HAND = [ "Right", "Left" ]

Coach.create()

50.times do
  c = Coach.create(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    username: Faker::Internet.user_name,
    current_city: Faker::Address.city,
    email: Faker::Internet.email,
    password: "password",
    current_state: Faker::Address.state_abbr,
    current_team: "The Coaches",
    date_of_birth: Faker::Date.birthday(25, 50),
    hockey_position: HOCKEY_POSITION.sample,
    hockey_hand: HOCKEY_HAND.sample,
    terms_and_conditions: true,
    type: "Coach"
  )
  
  puts c.errors.inspect
  
end

puts Coach.count

puts "completed seed"