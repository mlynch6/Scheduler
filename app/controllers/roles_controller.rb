class RolesController < ApplicationController
	def index
		@piece = Piece.find(params[:piece_id])
		@roles = @piece.roles.paginate(page: params[:page], per_page: params[:per_page])
	end
	
	def new
		form_setup
		@piece = Piece.find(params[:piece_id])
		@role = @piece.roles.build
	end
	
	def create
		@piece = Piece.find(params[:piece_id])
		@role = @piece.roles.build(params[:role])
		
		if @role.save
			flash[:success] = "Role created"
			redirect_to piece_roles_path(@piece)
		else
			form_setup
			render 'new'
		end
	end
	
	def edit
		@role = Role.includes(:piece).find(params[:id])
		@piece = @role.piece
		form_setup
	end
	
	def update
		@role = Role.includes(:piece).find(params[:id])
		
		if @role.update_attributes(params[:role])
			flash[:success] = "Role saved"
			redirect_to piece_roles_path(@role.piece_id)
		else
			form_setup
			@piece = @role.piece
			render 'edit'
		end
	end
	
	def destroy
		@role = Role.find(params[:id])
		@role.destroy
		flash[:success] = "Role deleted"
		redirect_to piece_roles_path(@role.piece_id)
	end
	
	private

	#setup for form - dropdowns, etc
	def form_setup
	end
end
