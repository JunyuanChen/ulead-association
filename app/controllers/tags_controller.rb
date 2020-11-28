class TagsController < ApplicationController
  before_action :ensure_signed_in!, except: %i[index show]
  before_action :set_tag, only: %i[show edit update destroy add_article remove_article]

  def index
    @tags = Tag.all.paginate page: params[:page]
  end

  def new
    @tag = Tag.new
  end

  def create
    @tag = Tag.new tag_params
    if @tag.save
      flash[:success] = "Created tag ##{@tag.name}."
      redirect_to @tag
    else
      flash[:danger] = 'Errors encountered when creating the tag.'
      render :new
    end
  end

  def show
    @article = @tag.articles.ordered.viewable_by(this_user).paginate page: params[:page]
  end

  def edit; end

  def update
    if @tag.update tag_params
      flash[:success] = 'Updated the tag.'
      redirect_to @tag
    else
      flash[:error] = 'Failed to update the tag.'
      render :edit
    end
  end

  def destroy
    flash[:secondary] = "Deleted tag ##{@tag.destroy.name}."
    redirect_to tags_path
  end

  def add_article
    @article = Article.find params[:article_id]
    if @tag.articles.include? @article
      flash[:warning] = "The article already has tag ##{@tag.name}."
    else
      @tag.articles << @article
      flash[:success] = "Added tag ##{@tag.name} to article \"#{@article.title}\"."
    end
    redirect_back fallback_location: edit_tags_path(@article)
  end

  def remove_article
    @article = Article.find params[:article_id]
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
end
