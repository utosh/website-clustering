class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites do |t|
      t.string :domain, null: false
      t.text :sitemap
      t.string :summary

      t.timestamps null: true
    end
  end
end
