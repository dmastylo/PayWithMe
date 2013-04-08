FactoryGirl.define do
	factory :organization do
		contact 'Test User'
		email 'sampleemail@email.com'
		name 'Sample Restaurant'
		split true
		deal false
		comment 'Test Comment'
	end
end