module RedmineIdobata
  module Patches
    module ProjectPatch
      def self.included(base)
        base.class_eval do
          safe_attributes 'idobata_webhook_url'
        end
      end
    end
  end
end
