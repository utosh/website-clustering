# encoding: utf-8

FactoryGirl.define do
  factory :site do
    domain "www.ruby.or.jp"
    # sitemap
    # summary
    created_at { Time.now - 3.day }
    updated_at { Time.now - 1.day }
  end
end
