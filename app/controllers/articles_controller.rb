class ArticlesController < ApplicationController
  before_action :ensure_signed_in!, except: %i[index show]
  before_action :ensure_reviewer!, only: :approve
  before_action :set_article, except: %i[index new create]
  before_action :ensure_edit_permission!, except: %i[index show new create]

  def index
    @articles = Article.ordered.viewable_by(this_user).paginate page: params[:page]
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new article_params.merge(author: this_user)
    if @article.save
      flash[:success] = "Created article \"#{@article.title}\"."
      redirect_to @article
    else
      render :new
    end
  end

  def show
    no_permission unless this_user&.can_view? @article

    @tags = @article.tags.ordered
  end

  def edit; end

  def update
    if @article.update article_params
      flash[:success] = 'Successfully updated the article.'
      redirect_to @article
    else
      render :edit
    end
  end

  def destroy
    flash[:dark] = "Deleted article \"#{@article.destroy.title}\"."
    redirect_to articles_path
  end

  def edit_tags
    @tags = @article.tags.ordered.paginate page: params[:tags_page]
    @results = Tag.all.paginate page: params[:tags_page]
  end

  def query_tags
    @tags = @article.tags.ordered.paginate page: params[:tags_page]
    @results = Tag.where('`name` LIKE ?', "%#{params[:query].gsub(/\s+/, '-')}%")
                  .or(Tag.where('`description` LIKE ?', "%#{params[:query]}%"))
                  .paginate(page: params[:results_page])
    render :edit_tags
  end

  def approve
    if @article.update approver: this_user
      flash[:success] = "Approved article #{@article.title}."
    else
      flash[:danger] = "Failed to approve the article: #{@article.errors.full_messages.first}."
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

  def ensure_edit_permission!
    return if this_user.can_edit? @article

    no_permission
  end
end
