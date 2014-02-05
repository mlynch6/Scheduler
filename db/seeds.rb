#Add Subscription Plans used by Stripe
subscription_plans = [
	[ "Beta", 0 ],
	[ "Dance Company", 15 ]
]
subscription_plans.each do |plan|
  SubscriptionPlan.find_or_create_by_name(:name => plan[0], :amount => plan[1])
end