class Site < ActiveRecord::Base
  has_many :contents

  validates :domain, presence: true

  # Class methods
  class << self
    def scraping!(url, depth: 2)
      domain, scheme, root = Crawler.decompose_url(url)
      site = self.new(domain: domain)

      crawler = Crawler.new(domain: domain, scheme: scheme, root: root)
      crawler.start(depth: depth)
      site.sitemap = crawler.sitemap.to_h
      site.contents = crawler.sitemap.contents.map do |c|
        Content.create_by_document(c)
      end
      site.save

      clustering = Clustering.new(site.contents)
      site.summary = clustering.analyze!
      site.save
      site
    end
  end

  # Instance methods
end
