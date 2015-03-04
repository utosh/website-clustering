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

  # def calc_idf(doc_num, counts)
  # end

  def all_document_term_counts
    @all_document_term_counts ||= documents.values.map(&:count_terms)
  end

  def idf
    @idf ||= begin
      freq = Hash.new(0)
      all_document_term_counts.each do |counts|
        counts.keys.each { |term| freq[term] += 1 }
      end

      _idf = {}
      document_count = all_document_term_counts.size
      freq.each do |term, count|
        _idf[term] = Math.log(document_count.to_f / count) + 1
      end

      _idf
    end
  end

  def tf_idf(term, document_id)
    document = documents[document_id]
    return unless document

    document.tf[term] * idf[term]
  end

  class Document
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
          counts[line.split("\t")[0]] += 1
        end

        counts
      end
    end

    # TODO: 中間値から一定以下のカウントの単語を除外する
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
