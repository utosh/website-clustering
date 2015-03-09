# encoding: utf-8

require 'natto'

class Clustering
  attr_reader :documents, :tokenizer

  def initialize(documents, tokenizer: MecabTokenizer.new)
    @tokenizer = tokenizer

    assigned_id = 1
    @documents = documents.inject({}) do |hash, d|
      hash[assigned_id] = Document.new(d, @tokenizer)
      assigned_id += 1
      hash
    end
  end

  def analyze!
    # term全部のtf-idf値を出してランキング化
    rankings = documents.map { |id, doc| Ranking.new(id, doc.tf) }
    # 上位のワードを特徴として出力
    rankings.map { |r| r.rank(10) }
    # (1)全体 (2)個別
  end

  def all_document_term_counts
    @all_document_term_counts ||= documents.values.map(&:count_terms)
  end

  def calc_idf(n, df_t)
    Math.log(n.to_f / df_t) + 1
  end

  def idf
    @idf ||= begin
      cross_appear_count = Hash.new(0)
      all_document_term_counts.each do |counts|
        counts.keys.each { |term| cross_appear_count[term] += 1 }
      end

      _idf = {}
      document_count = all_document_term_counts.size
      cross_appear_count.each do |term, count|
        _idf[term] = calc_idf(document_count, count)
      end

      _idf
    end
  end

  def tf_idf(term, document_id)
    memo_key = "#{term}:#{document_id}"
    memo = tf_idf_memo[memo_key]
    return memo if memo

    document = documents[document_id]
    return unless document

    tf_idf_memo[memo_key] = document.tf[term] * idf[term]
    tf_idf_memo[memo_key]
  end

  def tf_idf_memo
    @tf_idf_memo ||= {}
  end

  class Document
    TERM_COUNT_THRESHOLD = 2

    attr_reader :source, :tokenizer

    def self.format(source)
      source.to_s.gsub(/\t/, "").gsub(/\s{2,}/, " ").gsub(/\n+/, "\n")
    end

    def initialize(source, tokenizer)
      @source = self.class.format(source)
      @tokenizer = tokenizer
    end

    def token
      @token ||= tokenizer.parse(source)
    end

    def normalize(node)
    end

    def count_terms
      @counts ||= begin
        counts = Hash.new(0)

        compound_term = CompoundTerm.new
        token.each_line do |line|
          term = line.split("\t")[0].strip.gsub(/[,"'\\]/, "")

          case line
          when /名詞/
            if /接尾/.match(line)
              compound_term << [term, "接尾"]
              if str = compound_term.flush!
                counts[str] += 1
              end
            else
              unless compound_term.prev_pos == "名詞"
                if str = compound_term.flush!
                  counts[str] += 1
                end
              end

              compound_term << [term, "名詞"] unless /非自立/.match(line)
            end
          else
            if compound_term.any?
              if str = compound_term.flush!
                counts[str] += 1
              end
            end

            next unless /動詞\-自立|形容詞\-自立/.match(line)
            counts[term] += 1 if term.size >= 3
          end
        end

        counts.reject { |term, count| count <= TERM_COUNT_THRESHOLD }.to_h
      end
    end

    def tf
      @tf ||= begin
        sum = count_terms.values.sum

        _tf = {}
        count_terms.each do |term, count|
          _tf[term] = count.to_f / sum
        end

        _tf
      end
    end
  end

  class CompoundTerm
    def initialize(*words)
      @words = words.flatten
    end

    def <<(*args)
      word, part_of_speech = args.flatten[0,2]
      @words << [word, part_of_speech]
    end

    def prev_part_of_speech
      @words.last[1] if @words.any?
    end
    alias_method :prev_pos, :prev_part_of_speech

    def any?
      @words.any?
    end

    def empty?
      @words.empty?
    end

    def to_s
      @words.map { |word, part_of_speech| word }.join
    end

    def clear
      @words = []
    end

    def flush!
      str = to_s
      clear
      return str if str.size >= 2 and /[^\d]/.match(str)
    end
  end

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

  class MecabTokenizer
    def initialize(user_dict_path = nil)
      @tokenizer ||= user_dict_path ? Natto::MeCab.new("-u #{user_dict_path}") : Natto::MeCab.new("-Ochasen2")
    end

    def parse(document)
      @tokenizer.parse(document)
    end
  end
end
