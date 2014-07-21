# == Schema Information
#
# Table name: accounts
#
#  id                           :integer          not null, primary key
#  name                         :string(100)      not null
#  time_zone                    :string(100)      not null
#  status                       :string(20)       not null
#  cancelled_at                 :datetime
#  stripe_customer_token        :string(100)
#  current_subscription_plan_id :integer          not null
#  created_at                   :datetime         not null
#  updated_at                   :datetime         not null
#

class Account < ActiveRecord::Base
	STATUS_VALUES = ["Active", "Canceled"]

	attr_accessible :name, :time_zone, :stripe_card_token, :current_subscription_plan_id
	attr_accessor :stripe_card_token
  
	belongs_to :current_subscription_plan, class_name: "SubscriptionPlan"
	has_one :agma_contract, dependent: :destroy
	has_many :people, dependent: :destroy
	has_many :employees, dependent: :destroy
	has_many :users, dependent: :destroy
	has_many :addresses, :as => :addressable, dependent: :destroy
	has_many :phones, :as => :phoneable, dependent: :destroy
	has_many :locations, dependent: :destroy
	has_many :seasons, dependent: :destroy
	has_many :pieces, dependent: :destroy
	has_many :scenes, dependent: :destroy
	has_many :characters, dependent: :destroy
	has_many :season_pieces, dependent: :destroy
	has_many :casts, dependent: :destroy
	has_many :castings, dependent: :destroy
	has_many :events, dependent: :destroy
	has_many :event_series, dependent: :destroy
  
	before_validation :set_defaults, :if => "self.new_record?"
	after_create :create_contract
	before_destroy :destroy_stripe_customer
  
	validates :name, presence: true, length: { maximum: 100 }
	validates :time_zone,	presence: true, length: { maximum: 100 }, inclusion: { in: ActiveSupport::TimeZone.zones_map(&:name) }
	validates :status, presence: true, length: { maximum: 20 }, inclusion: { in: STATUS_VALUES }
	validates_datetime :cancelled_at, allow_blank: true
	validates :stripe_customer_token, length: { maximum: 100 }
	validates :current_subscription_plan_id,	presence: true
  
	default_scope order: 'name ASC'
  
	def self.current_id=(id)
		Thread.current[:account_id] = id
	end
  
	def self.current_id
		Thread.current[:account_id]
	end
  
	def save_with_payment
		if valid?
			self.errors.messages[:base] = nil
			customer = Stripe::Customer.create(description: name, plan: current_subscription_plan_id, card: stripe_card_token )
			self.stripe_customer_token = customer.id
			save!
		end
	rescue Stripe::InvalidRequestError => e
		logger.error "Stripe error while creating account for #{name}: #{e.message}"
		errors.add :base, "There was a problem with your credit card."
		false
	rescue Stripe::CardError => e
		logger.error "Stripe error while creating account for #{name}: #{e.message}"
		errors.add :base, "There was a problem with your credit card: #{e.message}"
		self.stripe_card_token = ""
		false
	end
	
	def list_invoices
		#if passing nil as customer, then invoices from all customers sent back
		self.stripe_customer_token = 0 if stripe_customer_token.blank?
		invoices = Stripe::Invoice.all(:customer => stripe_customer_token, :count => 12 )
		invoices.data
	rescue Stripe::InvalidRequestError => e
		logger.error "Stripe error while listing invoices: #{e.message}"
		errors.add :base, "There was a problem retreiving the invoices."
		false
	end
	
	def next_invoice_date
		next_invoice = Stripe::Invoice.upcoming(:customer => stripe_customer_token)
		Time.zone.at(next_invoice.next_payment_attempt).to_date
	rescue Stripe::InvalidRequestError => e
		logger.error "Stripe error while retrieving next invoice: #{e.message}"
		errors.add :base, "There was a problem retreiving the next invoice."
		nil
	end
	
	def cancel_subscription
		response = stripe_customer.cancel_subscription
		if response.status == 'canceled'
			self.status = 'Canceled'
			self.cancelled_at = Time.zone.now
			save!
		end
	rescue Stripe::InvalidRequestError => e
		logger.error "Stripe error while canceling subscription: #{e.message}"
		errors.add :base, "There was a problem canceling the subscription."
		false
	end
  
	def edit_subscription_payment
		self.errors.messages[:base] = nil
		response = stripe_customer.update_subscription(:plan => current_subscription_plan_id, :card => stripe_card_token, :prorate => true)
		true
	rescue Stripe::InvalidRequestError => e
		logger.error "Stripe error while updating the subscription payment for #{name}: #{e.message}"
		errors.add :base, "There was a problem with your credit card."
		false
	rescue Stripe::CardError => e
		logger.error "Stripe error while updating the subscription payment for #{name}: #{e.message}"
		errors.add :base, "There was a problem with your credit card: #{e.message}"
		self.stripe_card_token = ""
		false
	end
	
	def edit_subscription_plan
		if valid?
			self.errors.messages[:base] = nil
			response = stripe_customer.update_subscription(:plan => current_subscription_plan_id, :prorate => true)
			save!
		end
	rescue Stripe::InvalidRequestError => e
		logger.error "Stripe error while updating the subscription plan for #{name}: #{e.message}"
		errors.add :base, "There was a problem changing your subscription."
		false
	end
	
private
  
	def set_defaults
		self.status = 'Active' if status.blank?
	end
  
	def create_contract
		self.create_agma_contract
	end
	
	def stripe_customer
		@stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_token)
	end
	
	def destroy_stripe_customer
		self.errors.messages[:base] = nil
		response = stripe_customer.delete
		return response.deleted
	rescue Stripe::InvalidRequestError => e
		#Customer not found in Stripe
		true
	end
end
