# encoding: utf-8

module Clustering
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
end
