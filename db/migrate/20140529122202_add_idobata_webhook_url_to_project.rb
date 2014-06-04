class AddIdobataWebhookUrlToProject < ActiveRecord::Migration
  def change
    add_column :projects, :idobata_webhook_url, :string, :default => "", :null => false
  end
end
