# encoding: utf-8

FactoryGirl.define do
  module FactoryHelpers
    module_function
    def ruby_or_jp_top_html
      @ruby_or_jp_top_html ||= File.read(File.expand_path("../ruby_or_jp_top.html", __FILE__))
    end

    def wiki_ruby_text
      @wiki_ruby_text ||= File.read(Application.root + "spec/data/wikipedia/ruby.txt")
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
