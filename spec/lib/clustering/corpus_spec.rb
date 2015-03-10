require 'spec_helper'
require 'clustering/corpus'

# Class methods
RSpec.describe Clustering::Corpus, type: :lib do
end

# Instance methods
RSpec.describe Clustering::Corpus, type: :lib do
  before do
    @c = Clustering::Corpus.new(documents)
    @redis = Redis.new(Application.config.redis_connection)
    @redis.flushdb
  end

  after do
    @redis.flushdb
  end

  let(:documents) { [FactoryHelpers.wiki_ruby_text] }

  describe "#analyze!" do
    subject { @c.analyze! }

    let(:documents) do
      [
        FactoryHelpers.wiki_ruby_text,
        FactoryHelpers.read_data("matsue_about_ruby.txt"),
        FactoryHelpers.read_data("matsue_about_ruby2.txt"),
        FactoryHelpers.read_data("matsue_about_ruby3.txt")
      ]
    end

    it do
      expect{subject}.to_not raise_error
      expect(subject).to be_a(Array)
      # expect(@c).to receive(:tf_idf)
      # expect(subject).to eq [
      #   ["Ruby", "プログラミング"], # 全体
      #   [] # Document個別
      # ]
    end
  end

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
