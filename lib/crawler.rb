# encoding: utf-8
require 'nokogiri'
require 'open-uri'

class Crawler
  attr_reader :root, :depth, :sitemap, :memo

  class << self
    def open_document(url)
      doc = Nokogiri::HTML(OpenURI.open_uri(url))
      doc.css("script, stylesheet").map(&:remove)
      doc
    end

    def decompose_url(url)
      if m = %r!(?<scheme>https?)://(?<domain>[^\/]+)(?<path>.*)!.match(url)
        return m[:scheme], m[:domain], m[:path]
      end
    end
  end

  def initialize(domain:, scheme: 'http', root_path: '/')
    @domain, @scheme, @root = domain, scheme, root
    @root_path = "/" if @root_path.blank?
    @root = "#{scheme}://#{domain}#{root}"
    @sitemap = TreeNode.new
  end

  def start(depth: 2)
    top = self.open_document(root)
    memo[root] = true
    # TODO: depthまで階層を下ってクロールする
    sitemap.add top, crawl(parse_link(top))
  end

  def parse_link(doc)
    doc.css("a").map { |tag|
      url = tag.attributes["href"].to_s

      next if url.blank? or /\A#.*/.match(url) or /.(svg|png|jpg|gif)\z/.match(url)
      # TODO: URLの整形
      # unless //.match(url)
      # end

      url
    }.compact
  end

  def crawl(urls)
    urls.map { |url|
      next if memo[url]
      doc = self.class.open_document(url)
      memo[url] = true

      doc
    }.compact
  end

  def memo
    @memo ||= {}
  end
end

class DendrogramNode
  attr_accessor :left, :right

  def initialize(obj, left = nil, right = nil)
    @object = obj
    @left = left if left
    @right = right if right
  end
end
