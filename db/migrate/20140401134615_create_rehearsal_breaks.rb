# == Schema Information
#
# Table name: rehearsal_breaks
#
#  id               :integer          not null, primary key
#  agma_contract_id :integer          not null
#  break_min        :integer          not null
#  duration_min     :integer          not null
#  primary          :boolean          default(FALSE), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class CreateRehearsalBreaks < ActiveRecord::Migration
  def change
    create_table :rehearsal_breaks do |t|
      t.integer :agma_contract_id, :null => false
      t.integer :break_min, :null => false
      t.integer :duration_min, :null => false

      t.timestamps
    end
    
    add_index :rehearsal_breaks, :agma_contract_id
    add_index :rehearsal_breaks, [:agma_contract_id, :duration_min], unique: true
  end
end
