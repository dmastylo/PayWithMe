FactoryGirl.define do
	factory :organization do
		name 'Test User'
		email 'sampleemail@email.com'
		organization_name 'Sample Restaurant'
		split true
		deal false
		comment 'Test Comment'
	end
end