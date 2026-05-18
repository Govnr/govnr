class RelationshipsController < ApplicationController
before_action :authenticate_user!
 
  def create
    user = User.find(params[:followed_id])
    current_user.follow(user)
        redirect_to user
    # respond_to do |format|
    #   format.html { redirect_to user_path(@user) }
    #   format.js
    # end

  end

  def destroy
    user = Relationship.find(params[:id]).followed
    current_user.unfollow(user)
    redirect_to user
    # respond_to do |format|
    #   format.html { redirect_to user_path(@user) }
    #   format.js
    # end

  end

end
