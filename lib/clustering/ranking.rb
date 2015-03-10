# encoding: utf-8

module Clustering
  class Ranking
    delegate :redis, :namespace, to: "self.class"
    attr_reader :mykey, :data

    def self.redis
      @redis ||= Redis.new(Application.config.redis_connection)
    end

    def self.namespace
      "rank"
    end

    def initialize(id, data)
      raise ArgumentError if id.blank?
      @mykey = "#{namespace}:#{id}"
      @data = data
      create_ranking
    end

    def create_ranking
      if redis.exists(mykey)
        rank(-1)
      else
        create_ranking!
      end
    end

    def create_ranking!
      res = redis.multi do
        data.to_a.in_groups_of(100, false) do |group|
          redis.zadd mykey, group.map { |term, count| [count, encode_multibyte_char(term)] }
        end
        redis.zrevrange mykey, 0, -1#, with_scores: true
      end

      res[1]
    end

    def encode_multibyte_char(str)
      Base64.encode64(str)
    end

    def decode_multibyte_char(str)
      Base64.decode64(str).force_encoding("utf-8")
    end

    def rank(top = 5, with_scores: false)
      res = redis.zrevrange(mykey, 0, top, with_scores: with_scores)

      if with_scores
        res.to_a.map do |term, count|
          [decode_multibyte_char(term), count]
        end
      else
        res.to_a.map do |term|
          decode_multibyte_char(term)
        end
      end
    end
  end
end
