class StaticPagesController < ApplicationController
	authorize_resource :class => false
	
	def home
  end
  
  def features
  end
  
  def pricing
  end
  
  def contact
  end
	
private
	
	def use_https?
		false
	end
end
