require 'spec_helper'
require 'clustering/ranking'

RSpec.describe Clustering::Ranking, type: :lib do
  before do
    @redis = Redis.new(Application.config.redis_connection)
    @redis.flushdb
  end

  after do
    @redis.flushdb
  end

  describe "#create_ranking" do
    subject { @rank.create_ranking }

    before do
      @rank = Clustering::Ranking.new id, data
    end

    let(:id) { "plang" }
    let(:data) do
      {
        "Ruby"    => 34.5,
        "Python"  => 23.6,
        "Java"    => 49.0,
        "PHP"     => 35.2
      }
    end

    it "create ranking" do
      expect(subject).to eq ["Java", "PHP", "Ruby", "Python"]
      expect(@redis.zrevrange("rank:plang", 0, -1, with_scores: true).to_h).to eq({
        Base64.encode64("Java")   => 49.0,
        Base64.encode64("PHP")    => 35.2,
        Base64.encode64("Ruby")   => 34.5,
        Base64.encode64("Python") => 23.6
      })
    end
  end
end
