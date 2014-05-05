class Company::PublishCastsController < ApplicationController
	# This method should be an "update method" but some people will want to copy and paste the link.
	def update
		@sp = SeasonPiece.find(params[:id])
		@sp.update_attribute(:published, true)
		redirect_to season_piece_casts_path(@sp), :notice => "Successfully published all casts."
	end
end
