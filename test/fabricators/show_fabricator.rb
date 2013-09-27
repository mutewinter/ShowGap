Fabricator(:show) do
  title { Faker::HipsterIpsum.sentence(2).titlecase  }
  description { Faker::Lorem.paragraph }
  subdomain { sequence(:subdomain) { |i| "subdomain#{i}" } }
end
