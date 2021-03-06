class ForumsController < ApplicationController
  before_filter :store_location, :only => [:index, :show]
  before_filter :find_category
  before_filter :find_forum, :only => [:show]
  
  # Shows all root forums.
  # Limits this selection to forums the current user has access to.
  # Also gathers stats for the Compulsory Stat Box.
  def index
     if @category
      @forums = @category.forums.without_parent
    else
      # TODO: I encourage allcomers to find a better way.
      # FIXME: I have worked too long on this.
      # HELP: I need fresh eyes.
      @categories = Category.without_parent.select { |c| current_user.can?(:see_category, c) }
      @forums = Forum.without_category.without_parent.select { |f| current_user.can?(:see_forum, f) }
    end
    @lusers = User.recent.map { |u| u.to_s }.to_sentence
    @users = User.count
    @posts = Post.count
    @topics = Topic.count
    @ppt = @posts > 0 ? @posts / @topics : 0
    respond_to do |format|
      format.html
      format.xml { render :xml => @forums }
    end
  end
  
  # Shows a forum.
  # Checks first if the current user can see it.
  def show
    @topics = @forum.topics.sorted.paginate :page => params[:page], :per_page => 30, :order => "sticky DESC"
    @forums = @forum.children
    @all_forums = Forum.all(:select => "id, title", :order => "title ASC") - [@forum] if current_user.can?(:move_topics, @forum)
    @moderated_topics_count = @forum.moderations.topics.for_user(current_user).count
  end
  
  private
    def find_forum
      @forum = Forum.find(params[:id], :include => [{ :topics => :posts }, :moderations, :permissions])
      if !current_user.can?(:see_forum, @forum)
        flash[:notice] = t(:forum_permission_denied)
        redirect_to forums_path
      end
    end
    
    def find_category
      unless params[:category_id].blank?
        @category = Category.find(params[:category_id], :include => [:forums, :permissions])
        if !current_user.can?(:see_category, @category)
          flash[:notice] = t(:category_permission_denied)
          redirect_to root_path
        end
      end
    end
  
end
