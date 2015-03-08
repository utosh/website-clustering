class Content < ActiveRecord::Base
  TAG_PATTERN = %r!<[^>]+>!o

  belongs_to :site

  validates :path, presence: true

  # Class methods
  class << self
    def html2text(html, separator = " ")
      html.gsub(TAG_PATTERN, separator.to_s)
    end

    def create_by_document(path, doc)
      con = self.new
      con.path = path
      con.source = doc.to_s
      con.title = doc.css("title").text rescue nil
      con.description = extract_meta_content(doc, :description)
      con.keywords = extract_meta_content(doc, :keywords)
      # TODO
      # con.depth = doc.depth
      con.text = html2text(con.source)
      con.save!
      con
    end

    def extract_meta_content(doc, name)
      doc.css("meta[name=#{name}]").attribute("content").to_s rescue nil
    end
  end

  # Instance methods
end
