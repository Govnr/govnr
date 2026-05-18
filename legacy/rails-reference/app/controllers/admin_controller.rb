class AdminController < ApplicationController
before_filter :authenticate_user!, :authenticate_admin!
require 'yaml'

  def configuration

  end

  def update

    d = YAML::load_file(File.join(Rails.root, 'config', 'settings.yml'))
    d['petitions']['required_vote_percent'] = update_params[:petitions_required_vote_percent].to_f if update_params[:petitions_required_vote_percent].present?
    d['petitions']['expiry_time'] = update_params[:petitions_expiry_time].to_f if update_params[:petitions_expiry_time].present?
    d['motions']['delay_before_voting'] = update_params[:motions_delay_before_voting].to_f if update_params[:motions_delay_before_voting].present?
    d['motions']['voting_duration'] = update_params[:motions_voting_duration].to_f if update_params[:motions_voting_duration].present?
    d['motions']['required_majority_percent'] = update_params[:motions_required_majority_percent].to_f if update_params[:motions_required_majority_percent].present?
    File.open(File.join(Rails.root, 'config', 'settings.yml'), 'w') {|f| f.write d.to_yaml }
  	# Settings.petitions.required_vote_percent = update_params[:petitions_required_vote_percent] if update_params[:petitions_required_vote_percent].present?
  	# Settings.petitions.expiry_time = update_params[:petitions_expiry_time] if update_params[:petitions_expiry_time].present?
  	# Settings.motions.delay_before_voting = update_params[:motions_delay_before_voting] if update_params[:motions_delay_before_voting].present?
  	# Settings.motions.voting_duration = update_params[:motions_voting_duration] if update_params[:motions_voting_duration].present?
  	# Settings.motions.required_majority_percent = update_params[:motions_required_majority_percent] if update_params[:motions_required_majority_percent].present?
  	# Settings.reload!
  	redirect_to admin_configuration_path
  end

  private 
	def authenticate_admin!
		unless (current_user.has_role?(:admin))
			flash[:error] = "You don't have permission to access that page. Please <a href='*'>contact the support team</a> if you think this is an error."
			redirect_to root_path
		end
	end

	def update_params
    params.require(:update).permit(:petitions_required_vote_percent, :petitions_expiry_time, :motions_delay_before_voting, :motions_voting_duration, :motions_required_majority_percent)
  end
  			
end
