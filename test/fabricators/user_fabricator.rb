Fabricator(:user) do
  name { Faker::Name.name }
  nickname { |attrs| attrs[:name].downcase.underscore }
  description { Faker::Lorem.sentence }
  role { User::ROLES.sample }
  uid { sequence(:number, 1000000000)  }
end

# Create all of the user role Fabricators
# e.g. Fabricate(:listener) makes a User with the listener role
User::ROLES.each do |role|
  Fabricator(role.to_sym, from: :user) do
    role { role }
  end
end
