class Article < ApplicationRecord
  validates :title, presence: true
  validates :body, presence: true, length: { minimum: 15 }

  belongs_to :user
  has_and_belongs_to_many :tags

  before_save :render_markdown

  private

  def render_markdown
    renderer = Redcarpet::Render::XHTML.new with_toc_data: true,
                                            prettify: true,
                                            link_attribute: true
    markdown = Redcarpet::Markdown.new renderer,
                                       tables: true,
                                       fenced_code_blocks: true,
                                       autolink: true,
                                       strikethrough: true,
                                       lax_spacing: true,
                                       space_after_header: true,
                                       superscript: true,
                                       underline: true,
                                       highlight: true,
                                       quote: true,
                                       footnotes: true
    rendered_fragment = Loofah.fragment markdown.render(body)
    self.rendered = rendered_fragment.scrub!(:strip).to_s
    self.summary = rendered_fragment.to_text.truncate(256).split("\n").join(' ')
  end
end
