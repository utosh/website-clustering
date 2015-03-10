# encoding: utf-8

require 'natto'

module Clustering
  class Corpus
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
