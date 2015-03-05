# encoding: utf-8

require 'natto'

class Clustering
  attr_reader :documents, :tokenizer

  def initialize(documents, tokenizer: MecabTokenizer.new)
    @tokenizer = tokenizer

    tmp_num = 1
    @documents = documents.inject({}) do |hash, d|
      hash[tmp_num] = Document.new(d, @tokenizer)
      tmp_num += 1
      hash
    end
  end

  def cluster!
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

    def count_terms
      @counts ||= begin
        counts = Hash.new(0)

        token.each_line do |line|
          next unless /名詞/.match(line)
          term = line.split("\t")[0].strip

          if /\w+/.match(term) and term.size > 1 and /[^\d]/.match(term)
            counts[term] += 1
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

  class MecabTokenizer
    def initialize(user_dict_path = nil)
      @tokenizer ||= user_dict_path ? Natto::MeCab.new("-u #{user_dict_path}") : Natto::MeCab.new("-Ochasen2")
    end

    def parse(document)
      @tokenizer.parse(document)
    end
  end
end
