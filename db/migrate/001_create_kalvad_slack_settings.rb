# frozen_string_literal: true

class CreateKalvadSlackSettings < ActiveRecord::Migration[7.2]
  def change
    create_table :kalvad_slack_settings do |t|
      t.references :project, null: false, index: { unique: true }, foreign_key: true
      t.string  :webhook_url
      t.string  :channel
      t.integer :enabled,                       default: 0, null: false
      t.integer :post_issue_created,            default: 0, null: false
      t.integer :post_issue_updated,            default: 0, null: false
      t.integer :post_issue_closed,             default: 0, null: false
      t.integer :post_wiki_created,             default: 0, null: false
      t.integer :post_wiki_updated,             default: 0, null: false
      t.integer :post_news,                     default: 0, null: false
      t.integer :post_private_issues,           default: 0, null: false
      t.integer :post_private_notes,            default: 0, null: false
      t.integer :display_watchers,              default: 0, null: false
      t.integer :display_description_on_create, default: 0, null: false
      t.integer :auto_mentions,                 default: 0, null: false
      t.string  :mention_keywords
      t.timestamps
    end
  end
end
