# encoding: utf-8

FactoryGirl.define do
  module FactoryHelpers
    module_function
    def ruby_or_jp_top_html
      read_data("ruby_or_jp_top.html")
    end

    def wiki_ruby_text
      read_data("wikipedia/ruby.txt")
    end

    def read_data(path)
      @data ||= {}
      @data[path] ||= begin
        data_path = Application.root + "spec/data" + path.sub(/\A[\.\/]+/, "")
        File.read(data_path) if File.exist?(data_path)
      end
    end
  end

  factory :content do
    path "/ja/"
    source { ruby_or_jp_top_html }
    title "Rubyアソシエーション: トップページ"
    description "Rubyアソシエーションは、プログラミング言語Rubyの普及と発展のための組織です。"
    keywords "Ruby,Ruby Association,ルビー,ルビーアソシエーション"
    # text
    # clusters
    # summary
    created_at { Time.now - 3.day }
    updated_at { Time.now - 1.day }
  end
end
