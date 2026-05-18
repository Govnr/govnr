class CommentsController < ApplicationController
  before_filter :authenticate_user!
  before_action :set_group, only: [:create]
  
  def show
    @commentable = find_commentable
    @comment = Comment.find(params[:id])
  end

  def new
    @parent_id = params.delete(:parent_id)
    @commentable = find_commentable
    @comment = Comment.new( :parent_id => @parent_id, 
                            :commentable_id => @commentable.id,
                            :commentable_type => @commentable.class.to_s,
                            :user_id => current_user.id)
  end
  
  def create
    @commentable = find_commentable
    @comment = @commentable.comments.build(comment_params)
    @comment.user_id = current_user.id;
    @comment.parent_id = comment_params[:parent_id]
    if @comment.save
      flash[:notice] = "Successfully created comment."
      redirect_to [@commentable.group,@commentable]
    else
      flash[:error] = "Error adding comment."
    end
  end

  def report
    @commentable = comment_params[:commentable_type].classify.constantize.find(comment_params[:commentable_id])
    @comment = @commentable.comments.find(comment_params[:id])
    @comment.reported = 1;
    @comment.reporter_id = current_user.id;
    @comment.report_reason = comment_params[:report_reason]
    @comment.report_comment = comment_params[:report_comment]
    if @comment.save
      flash[:notice] = "Successfully reported comment."
      redirect_to [@commentable.group,@commentable]
    else
      flash[:error] = "Error reporting comment."
    end
    respond_to do |format|
        format.html { }
        format.js { }
      end
  end

  def upvote
    @commentable = params[:commentable_type].classify.constantize.find(params[:commentable_id])
    @comment = @commentable.comments.find(params[:comment_id])
    @comment.upvote_by current_user
    @comment.create_activity :upvote, owner: current_user
    if @comment.save
      flash[:notice] = "Successfully upvoted comment."
      redirect_to [@commentable.group,@commentable]
    else
      flash[:error] = "Error upvoting comment."
    end
    respond_to do |format|
        format.html { }
        format.js { }
      end
  end

  def downvote
    @commentable = params[:commentable_type].classify.constantize.find(params[:commentable_id])
    @comment = @commentable.comments.find(params[:comment_id])
    @comment.downvote_by current_user
    @comment.create_activity :downvote, owner: current_user
    if @comment.save
      flash[:notice] = "Successfully downvoted comment."
      redirect_to [@commentable.group,@commentable]
    else
      flash[:error] = "Error downvoted comment."
    end
  end
 
  private
    # Use callbacks to share common setup or constraints between actions.
  def set_group
    @group = Group.friendly.find(params[:comment][:group_id])
  end

  def find_commentable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        if (name == 'group_id')
          return Group.friendly.find(value)
        else
          return $1.classify.constantize.find(value)
        end
      end
    end
    nil
  end
  def comment_params
    params.require(:comment).permit(:group_id, :content, :parent_id, :rating, :upvotes, :downvotes, :report_reason, :report_comment, :status, :commentable_id, :commentable_type, :id)
  end
end