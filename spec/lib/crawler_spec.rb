require 'spec_helper'
require 'crawler'

# Class methods
RSpec.describe Crawler, type: :lib do
  before do
    allow(OpenURI).to receive(:open_uri) do |*args|
      File.open(Application.root + "spec/data/ruby_or_jp_top.html")
    end
  end

  describe "crawl" do
    subject { Crawler.crawl url }

    let(:url) { "http://hoge.com" }

    before do
      @spy = spy("Crawler")
      allow(Crawler).to receive(:new).and_return(@spy)
    end

    it do
      subject
      expect(@spy).to have_received(:start).with(depth: 2)
      expect(@spy).to have_received(:sitemap)
    end
  end

  describe "open_document" do
    subject { Crawler.open_document url }

    let(:url) { "http://www.ruby.or.jp/ja/" }

    it do
      expect(subject).to be_a Nokogiri::HTML::Document
    end

    it "reject all script-tag and stylesheet-tag" do
      html = subject.to_s
      expect(html).to_not match %r!<script.*>.*</script>!
      expect(html).to_not match %r!<stylesheet.*>.*</stylesheet>!
    end
  end
end

# Instance methods
RSpec.describe Crawler, type: :model do
  before do
    allow(OpenURI).to receive(:open_uri) do |*args|
      File.open(Application.root + "spec/data/ruby_or_jp_top.html")
    end

    @crawler = Crawler.new(args)
  end

  let (:args) do
    {
      domain: "www.ruby.or.jp"
    }
  end

  # TODO: test
  describe "#start" do
    subject { @crawler.start }

    it do
      expect{subject}.to_not raise_error
    end
  end

  # TODO: test
  describe "#parse_link" do
    subject { @crawler.parse_link doc }

    let(:doc) { Nokogiri::HTML(FactoryHelpers.read_data("wikipedia/ruby.html")) }

    it do
      # TODO: scheme://domain/path
      # expect(subject.first).to match %r!https?://.+!
    end
  end

  describe "#crawl" do
    subject { @crawler.crawl urls }

    let(:urls) { ["www.ruby.or.jp"] }

    it do
      expect(subject.first ).to be_a Nokogiri::HTML
    end
  end
end
