# frozen_string_literal: true

class RecreateKalvadSlackSettings < ActiveRecord::Migration[7.2]
  def up
    drop_table :kalvad_slack_settings, if_exists: true

    create_table :kalvad_slack_settings do |t|
      t.references :project, null: false, index: { unique: true }, foreign_key: true
      t.string  :webhook_url, null: false, default: ''
      t.string  :channel,     null: false, default: ''
      t.string  :username,    null: false, default: 'Redmine'
      t.string  :icon,        null: false, default: ''
      t.boolean :enabled,                       null: false, default: true
      t.boolean :post_issue_created,            null: false, default: true
      t.boolean :post_issue_updated,            null: false, default: true
      t.boolean :post_issue_closed,             null: false, default: true
      t.boolean :post_wiki_created,             null: false, default: false
      t.boolean :post_wiki_updated,             null: false, default: false
      t.boolean :post_news,                     null: false, default: true
      t.boolean :post_private_issues,           null: false, default: false
      t.boolean :post_private_notes,            null: false, default: false
      t.boolean :display_watchers,              null: false, default: false
      t.boolean :display_description_on_create, null: false, default: true
      t.timestamps
    end
  end

  def down
    drop_table :kalvad_slack_settings, if_exists: true
  end
end
