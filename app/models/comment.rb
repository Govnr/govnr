class Comment < ActiveRecord::Base
  has_ancestry
  acts_as_votable
  belongs_to :commentable, :polymorphic => true
  include PublicActivity::Model
  tracked except: :update, owner: Proc.new{ |controller, model| controller.current_user }
end