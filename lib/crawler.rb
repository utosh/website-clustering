require 'nokogiri'
require 'open-uri'

class Crawler
  attr_reader :url, :depth, :sitemap

  class << self
    def crawl(url, depth: 2)
      domain, scheme, root = decompose_url(url)
      crawler = self.new(domain: domain, scheme: scheme, root: root)
      crawler.start(depth: depth)
      crawler.sitemap
    end

    def decompose_url(url)
      if m = %r!(?<scheme>https?)://(?<domain>[^\/]+)(?<path>.*)!.match(url)
        return m[:scheme], m[:domain], m[:path]
      end
    end

    def open_document(url)
      doc = Nokogiri::HTML(OpenURI.open_uri(url))
      doc.css("script, stylesheet").map(&:remove)
      doc
    end
  end

  def initialize(domain:, scheme: 'http', root: '/')
    @domain, @scheme, @root = domain, scheme, root
    @root = "/" if @root.blank?
    @url = "#{scheme}://#{domain}#{root}"
    @sitemap = {}
  end

  def start(depth: 2)
  end
end
