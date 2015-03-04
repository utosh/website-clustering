require 'spec_helper'
require 'crawler'

# Class methods
RSpec.describe Crawler, type: :lib do
  before do
    allow(OpenURI).to receive(:open_uri) do |*args|
      File.open(Application.root + "spec/factories/ruby_or_jp_top.html")
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

  describe "decompose_url" do
    subject { Crawler.decompose_url url }
    let(:url) { "http://hoge.com" }

    it do
      expect(subject).to eq ["http", "hoge.com", ""]
    end

    context "pattern2" do
      let(:url) { "https://www-hoge.tokyo/aaaaaaa?hoge=fuga" }

      it do
        expect(subject).to eq ["https", "www-hoge.tokyo", "/aaaaaaa?hoge=fuga"]
      end
    end

    context "when given url is invalid format" do
      let(:url) { "hoge.com" }

      it do
        expect(subject).to be_nil
      end
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
      File.open(Application.root + "spec/factories/ruby_or_jp_top.html")
    end

    @content = Crawler.new(args)
  end

  let (:args) do
    {
      domain: "www.ruby.or.jp"
    }
  end

  describe "#start" do
    subject { @content.start }

    it do
      expect{subject}.to_not raise_error
    end
  end
end
