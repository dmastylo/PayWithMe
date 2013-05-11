ab_test "Homepage options" do
	description "Different homepage options leading to more/less signups"
	alternatives "default", "social", "alternative"
	metrics :signup
	default "default"
end