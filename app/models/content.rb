class Content < ActiveRecord::Base
  TAG_PATTERN = %r!<[^>]+>!o

  belongs_to :site

  validates :path, presence: true

  # Class methods
  class << self
    def html2text(html, separator = " ")
      html.gsub(TAG_PATTERN, separator.to_s)
    end
  end

  # Instance methods
end
