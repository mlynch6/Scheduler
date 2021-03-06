# == Schema Information
#
# Table name: seasons
#
#  id         :integer          not null, primary key
#  account_id :integer          not null
#  name       :string(30)       not null
#  start_dt   :date             not null
#  end_dt     :date             not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Season < ActiveRecord::Base
  attr_accessible :name, :start_dt, :end_dt
  attr_accessible :piece_ids
  
  belongs_to :account
  has_many :season_pieces, dependent: :destroy
	has_many :pieces, through: :season_pieces
	has_many :lecture_demos, 		dependent: :destroy, inverse_of: :season
	has_many :costume_fittings, dependent: :destroy, inverse_of: :season
	has_many :rehearsals, 			dependent: :destroy, inverse_of: :season
	has_many :company_classes, 	dependent: :destroy, inverse_of: :season
  
  validates :name, presence: true, length: { maximum: 30 }
  validates_date :start_dt
	validates :start_dt,	presence: true
	validates_date :end_dt, :after => :start_dt, :after_message => "must be after the Start Date"
	validates :end_dt,	presence: true
	
	default_scope lambda { order('start_dt DESC').where(:account_id => Account.current_id) }
end
