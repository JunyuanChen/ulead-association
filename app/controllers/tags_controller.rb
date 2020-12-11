class TagsController < ApplicationController
  before_action :ensure_signed_in!, except: %i[index show]
  before_action :set_tag, except: %i[index new create]
  before_action :set_article, only: %i[add_article remove_article]
  before_action :ensure_edit_permission!, only: %i[add_article remove_article]

  # GET /tags
  def index
    @tags = Tag.all.paginate page: params[:page]
    fresh_when @tags
  end

  # GET /tags/new
  def new
    @tag = Tag.new
  end

  # POST /tags
  def create
    @tag = if params[:query].present?
             Tag.new name: params[:query]
           else
             Tag.new tag_params
           end

    if @tag.save
      flash[:success] = "Created tag ##{@tag.name}."
      if params[:query].present?
        redirect_back fallback_location: @tag
      else
        redirect_to @tag
      end
    else
      flash[:danger] = 'Errors encountered when creating the tag.'
      render :new
    end
  end

  # GET /tags/:id
  def show
    fresh_when @tag

    @articles = @tag.articles
                    .ordered
                    .viewable_by(this_user)
                    .includes(:tags)
                    .includes_if(this_user&.permission?(:reviewer),
                                 :author,
                                 :approver)
                    .paginate(page: params[:page])
  end

  # GET /tags/:id/edit
  def edit; end

  # PATCH /tags/:id
  def update
    if @tag.update tag_params
      flash[:success] = 'Updated the tag.'
      redirect_to @tag
    else
      flash[:error] = 'Failed to update the tag.'
      render :edit
    end
  end

  # DELETE /tags/:id
  def destroy
    flash[:secondary] = "Deleted tag ##{@tag.destroy.name}."
    redirect_to tags_path
  end

  # PATCH /tags/:id/add_article
  def add_article
    if @tag.articles.include? @article
      flash[:warning] = "The article already has tag ##{@tag.name}."
    else
      @tag.articles << @article
      flash[:success] = "Added tag ##{@tag.name} to article \"#{@article.title}\"."
    end
    redirect_back fallback_location: edit_tags_path(@article)
  end

  # PATCH /tags/:id/remove_article
  def remove_article
    if @tag.articles.include? @article
      @tag.articles.delete @article
      flash[:secondary] = "Removed tag ##{@tag.name} from article \"#{@article.title}\"."
    else
      flash[:warning] = "The article does not have tag ##{@tag.name}."
    end
    redirect_back fallback_location: edit_tags_path(@article)
  end

  private

  def tag_params
    params.require(:tag).permit(:name, :description)
  end

  def set_tag
    @tag = Tag.find params[:id]
  end

  def set_article
    @article = Article.find params[:article_id]
  end

  def ensure_edit_permission!
    return if this_user.can_edit? @article

    no_permission
  end
end
