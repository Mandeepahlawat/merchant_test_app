# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Merchant.create(name: "Vipin", email: "abc@email.com", status: 1, about: "This is a seeded merchant.", gender: 1, price: 10.2, avg_rating: 2, review_count: 2)
Merchant.create(name: "Sample User", email: "abc1@email.com", status: 1, about: "This is a sample seeded merchant.", gender: 0, price: 50, avg_rating: 3, review_count: 5)
Merchant.create(name: "Sample User 1", email: "abc2@email.com", status: 1, about: "This is another sample seeded merchant.", gender: 2, price: 30, avg_rating: 5, review_count: 1)

["Massage", "Waxing", "Hair Cut", "Yoga"].each {|text| Specialization.create(name: text)}

Merchant.all.each do |m| 
	10.times do
		random_no = (0..200).to_a.sample
		m.openings.create(start_time: (Time.now + random_no.hours), end_time: (Time.now + random_no.hours + random_no.minutes), status: (0..2).to_a.sample)
	end

	2.times do
		m.specializations << Specialization.all.sample
	end
end
