class CreateContents < ActiveRecord::Migration
  def change
    create_table :contents do |t|
      t.string :path, null: false
      # t.string :query
      # t.string :page
      t.text :source
      t.string :title
      t.text :description
      t.text :keywords
      t.text :text
      t.text :clusters
      t.string :summary

      t.timestamps null: true
    end
  end
end
