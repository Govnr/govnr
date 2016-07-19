ActiveAdmin.register User do

permit_params :email, :first_name, :last_name, :address, :postcode, 
				:encrypted_password, :salt, :created_at, :updated_at,
				:reset_password_token, :reset_password_sent_at, :remember_created_at,
				:sign_in_count, :current_sign_in_at, :last_sign_in_at, :current_sign_in_ip,
				:last_sign_in_ip, :confirmation_token, :confirmed_at, :confirmation_sent_at,
				:unconfirmed_email, :failed_attempts, :unlock_token, :locked_at, :roles

# See permitted parameters documentation:
# https://github.com/activeadmin/activeadmin/blob/master/docs/2-resource-customization.md#setting-up-strong-parameters
#
# permit_params :list, :of, :attributes, :on, :model
#
# or
#
# permit_params do
#   permitted = [:permitted, :attributes]
#   permitted << :other if params[:action] == 'create' && current_user.admin?
#   permitted
# end


end
