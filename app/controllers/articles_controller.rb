class ArticlesController < ApplicationController
  before_action :ensure_signed_in!, except: %i[index show]
  before_action :ensure_reviewer!, only: :approve
  before_action :ensure_developer!, only: :hide
  before_action :set_article, except: %i[index new create]
  before_action :ensure_edit_permission!, except: %i[index show new create]

  # GET /articles
  def index
    @articles = Article.ordered
                       .viewable_by(this_user)
                       .includes(:tags)
                       .includes_if(this_user&.permission?(:reviewer),
                                    :author,
                                    :approver)
                       .paginate(page: params[:page])
  end

  # GET /articles/new
  def new
    @article = Article.new
  end

  # POST /articles
  def create
    @article = Article.new article_params.merge(author: this_user)
    if @article.save
      flash[:success] = "Created article \"#{@article.title}\"."
      redirect_to @article
    else
      render :new
    end
  end

  # GET /articles/:id
  def show
    no_permission unless this_user!.can_view? @article

    @tags = @article.tags.ordered
  end

  # GET /articles/:id/edit
  def edit; end

  # PATCH /articles/:id
  def update
    if @article.update article_params
      flash[:success] = 'Successfully updated the article.'
      redirect_to @article
    else
      render :edit
    end
  end

  # DELETE /articles/:id
  def destroy
    flash[:dark] = "Deleted article \"#{@article.destroy.title}\"."
    redirect_to articles_path
  end

  # GET /articles/:id/edit_tags
  def edit_tags
    @tags = @article.tags.ordered.paginate page: params[:tags_page]
    @results = Tag.all.paginate page: params[:tags_page]
  end

  # POST /articles/:id/edit_tags
  def query_tags
    @tags = @article.tags.ordered.paginate page: params[:tags_page]
    @results = Tag.where('`name` LIKE ?', "%#{params[:query].gsub(/\s+/, '-')}%")
                  .or(Tag.where('`description` LIKE ?', "%#{params[:query]}%"))
                  .paginate(page: params[:results_page])
    render :edit_tags
  end

  # PATCH /articles/:id/approve
  def approve
    if @article.update approver: this_user, published_at: Time.now
      flash[:success] = "Approved article #{@article.title}."
    else
      flash[:danger] = "Failed to approve the article: #{@article.errors.full_messages.first}."
    end
    redirect_back fallback_location: @article
  end

  # PATCH /articles/:id/hide
  def hide
    if @article.update hidden: params[:hidden]
      flash[:success] = "Article #{@article.title} will be #{@article.hidden? ? 'hidden' : 'listed'} in the index."
    else
      flash[:danger] = "Cannot hide the article: #{@article.errors.full_messages.first}."
    end
    redirect_back fallback_location: @article
  end

  private

  def article_params
    params.require(:article).permit(:title, :body)
  end

  def set_article
    @article = Article.find params[:id]
  end

  # Call `no_permission' unless this user can edit the article
  def ensure_edit_permission!
    return if this_user.can_edit? @article

    no_permission
  end
end
