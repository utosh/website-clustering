require 'spec_helper'
require 'clustering'

# Class methods
RSpec.describe Clustering, type: :lib do
end

# Instance methods
RSpec.describe Clustering, type: :lib do
  before do
    @c = Clustering.new(documents)
  end

  let(:documents) { [FactoryHelpers.wiki_ruby_text] }

  describe "#idf" do
    subject { @c.idf }

    before do
      allow_any_instance_of(Clustering::Document).to receive(:count_terms).and_return({"Ruby" => 10})
    end

    it do
      expect(subject).to be_a(Hash)
      expect(subject["Ruby"]).to eq 1.0
    end
  end

  describe "#tf_idf" do
    subject { @c.tf_idf "Ruby", 1 }

    before do
      allow_any_instance_of(Clustering::Document).to receive(:count_terms).and_return({"Ruby" => 10})
    end

    it do
      expect{subject}.to_not raise_error
      expect(subject).to eq 1.0
    end
  end
end


RSpec.describe Clustering::Document, type: :lib do
  describe "format" do
    subject { Clustering::Document.format(source) }

    let(:source) { FactoryHelpers.wiki_ruby_text }

    it { expect(subject).to_not match %r!\t! }
    it { expect(subject).to_not match %r!\s{2,}! }
    it { expect(subject).to_not match %r!\n{2,}! }
  end

  describe "Instance methods" do
    before do
      @doc = Clustering::Document.new source, tokenizer
    end

    let(:source) { FactoryHelpers.wiki_ruby_text }
    let(:tokenizer) { Natto::MeCab.new("-Ochasen2") }

    describe "#count_terms" do
      subject { @doc.count_terms }

      before do
        stub_const("Clustering::Document::TERM_COUNT_THRESHOLD", 1)
      end

      let(:source) do
        <<-TEXT
（１）Ruby（ルビー）とは？

　Rubyとは、島根県松江市在住のまつもとゆきひろさんが考えたプログラミング言語です。ですので、言いかえると方言（松江弁）を話して（書いて）コンピュータを動かすことができるようになったということです。しかもコンピュータの世界は国境などありませんから、この松江弁は日本人だけでなく世界の人たちが自由に話せる（使える）言語になったのです。

　ちなみにRubyという名前は宝石のルビーから名付けられました。なぜ宝石から名付けられたかというと、当時、宝石の真珠（パール）にちなんだPerl（パール）という名前のプログラミング言語がありました（今もあります）。そこでこちらも宝石の名前が良いねという話になりました。なぜルビーにしたかというと、当時のまつもとさんの会社の同僚が7月生まれで、7月の誕生石がルビーだったからです。

[書籍]
たのしいRuby 第4版
初めてのRuby
たのしい開発 スタートアップRuby
パーフェクトRuby
RailsによるアジャイルWebアプリケーション開発 第4版
プログラミング言語Ruby
Rubyベストプラクティス -プロフェッショナルによるコードとテクニック
メタプログラミングRuby
        TEXT
      end

      it do
        expect(subject).to be_a(Hash)
        expect(subject["Ruby"]).to eq source.scan(/Ruby/).size
      end

      it "reject less than count-threshold" do
        expect(subject.values.min).to be > 1
      end
    end

    describe "#tf" do
      subject { @doc.tf }

      it do
        expect(subject).to be_a(Hash)
      end

      it do
        expect(subject.keys.any? { |term| /\A\s.+\s\z/.match(term) } ).to be_falsey
      end

      it "reject meaningless terms" do
        expect(subject["."]).to be_nil
        expect(subject["|"]).to be_nil
        expect(subject["1"]).to be_nil
        expect(subject["p"]).to be_nil
      end

      it do
        expect(subject["Ruby"]).to be < 1 # TODO: ちゃんとテストする
      end
    end
  end
end


RSpec.describe Clustering::MecabTokenizer, type: :lib do
  before do
    @tokenizer = Clustering::MecabTokenizer.new
  end

  describe "parse" do
    subject { @tokenizer.parse document }

    let(:document) { "" }

    it do
      expect{subject}.to_not raise_error
    end
  end
end
