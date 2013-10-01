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
	STATUS_VALUES = ["Registering", "Trialing", "Active", "Past_due", "Canceled"]

  attr_accessible :name, :time_zone, :stripe_card_token, :current_subscription_plan_id
  attr_accessible :addresses_attributes, :phones_attributes, :employees_attributes
  attr_accessor :stripe_card_token
  
  belongs_to :current_subscription_plan, class_name: "SubscriptionPlan"
  has_one :agma_profile, dependent: :destroy
  has_many :employees, dependent: :destroy
  has_many :users, dependent: :destroy
  has_many :addresses, :as => :addressable, dependent: :destroy
  has_many :phones, :as => :phoneable, dependent: :destroy
  has_many :seasons, dependent: :destroy
  has_many :locations, dependent: :destroy
  has_many :pieces, dependent: :destroy
  has_many :scenes, dependent: :destroy
  has_many :characters, dependent: :destroy
  has_many :events, dependent: :destroy
  
  accepts_nested_attributes_for :addresses
  accepts_nested_attributes_for :phones
  accepts_nested_attributes_for :employees
  
  before_validation :set_defaults, :if => "self.new_record?"
  after_create :create_profile
  
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
  		customer = Stripe::Customer.create(description: name, plan: current_subscription_plan_id, card: stripe_card_token )
  		self.stripe_customer_token = customer.id
  		save!
  	end
  rescue Stripe::InvalidRequestError => e
  	logger.error "Stripe error while creating account for #{name}: #{e.message}"
  	errors.add :base, "There was a problem with your credit card."
  	false
	end
	
	def list_subscription_invoices
  	Stripe::Invoice.all(customer: stripe_customer_token, count: 12 )
  rescue Stripe::InvalidRequestError => e
  	logger.error "Stripe error while listing invoices: #{e.message}"
  	errors.add :base, "There was a problem retreiving the invoices."
  	false
	end
	
	def cancel_subscription
		response = stripe_customer.cancel_subscription
		self.status = 'Canceled'
  	self.cancelled_at = Time.zone.now
  	save!
	end
  
 private
  
  def set_defaults
		self.status = 'Active' if status.blank?
	end
  
  def create_profile
		p = AgmaProfile.new
		p.account_id = id
		p.rehearsal_start_time = '9 AM'
		p.rehearsal_end_time = '6 PM'
		p.rehearsal_max_hrs_per_week = 30
		p.rehearsal_max_hrs_per_day = 6
		p.rehearsal_increment_min = 30
		p.class_break_min = 15
		p.rehearsal_break_min_per_hr = 5
		p.costume_increment_min = 15
		p.save
	end
	
	def stripe_customer
    @stripe_customer ||= Stripe::Customer.retrieve(stripe_customer_token)
  end
end
