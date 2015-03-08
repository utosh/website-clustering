require 'spec_helper'

# Class methods
RSpec.describe Content, type: :model do
  describe "html2text" do
    subject { Content.html2text html, separator }

    let(:html) { "<html><body><div><h1>Hello</h1><p>Paragraph1</p></div></body></html>" }
    let(:separator) { "" }

    it do
      expect(subject).to eq "HelloParagraph1"
    end

    context "parse real-html" do
      let(:html) { FactoryHelpers.ruby_or_jp_top_html }

      it do
        expect(subject).to_not match %r!<[^>]+>!
      end
    end
  end
end

# Instance methods
RSpec.describe Content, type: :model do
  before do
    allow(OpenURI).to receive(:open_uri) do |*args|
      File.open(Application.root + "spec/data/ruby_or_jp_top.html")
    end

    @content = FactoryGirl.create(:content)
  end
end
