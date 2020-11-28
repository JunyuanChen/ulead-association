require 'test_helper'

class ArticleTest < ActiveSupport::TestCase
  setup do
    @user = User.new username: 'article_test',
                     password: 'p@$$w0rd!'
    @user.save!
  end

  test 'should reject empty title' do
    @article = Article.new body: 'the best article in the world',
                           author: @user
    assert_not @article.save, 'Saved an article without title'
  end

  test 'should reject empty body' do
    @article = Article.new title: 'good article',
                           author: @user
    assert_not @article.save, 'Saved an article without body'
  end

  test 'should reject short articles' do
    @article = Article.new title: 'a short article',
                           body: 'short',
                           author: @user
    assert_not @article.save, 'Saved an short article with body "short"'
  end

  test 'should reject empty author' do
    @article = Article.new title: 'a valid article',
                           body: 'this is a valid article *with* __markdown__. The quick brown fox jumped over the lazy dog.'
    assert_not @article.save, 'Saved an article without an author'
  end

  test 'should accept valid articles' do
    @article = Article.new title: 'a valid article',
                           body: 'this is a valid article *with* __markdown__. The quick brown fox jumped over the lazy dog.',
                           author: @user
    assert @article.save, 'Rejected a valid article'
  end

  test 'should render markdown' do
    @article = Article.new title: 'markdown is supported!!!',
                           body: '__markdown__ is a *simple* markup language to ~~write~~ articles with.',
                           author: @user
    @article.save!

    assert_includes @article.rendered, '<strong>markdown</strong>'
    assert_includes @article.rendered, '<em>simple</em>'
    assert_includes @article.rendered, '<del>write</del>'
  end

  test 'should sanitize rendered HTML' do
    @article = Article.new title: 'XSS warning',
                           body: '<a href="javascript:alert(\'XSS!\');">click me</a><script>alert("oh no!");</script>',
                           author: @user
    @article.save!

    assert_not_includes @article.rendered, 'javascript'
    assert_not_includes @article.rendered, '<script>'
    assert_not_includes @article.rendered, '</script>'
  end

  test 'should generate summary' do
    @article = Article.new title: 'Summary',
                           body: 'this is an __article__ used for testing *summary generation*.',
                           author: @user
    @article.save!

    assert_includes @article.summary, 'this is an article used for testing summary generation.'
  end
end
