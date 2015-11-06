Redmine::Plugin.register :redmine_idobata do
  name 'Redmine Idobata plugin'
  author 'Hiro Kawasaki'
  description 'Idobata.io chat integration'
  version '1.1.0'
  url 'https://github.com/kawahiro311/redmine_idobata'
  author_url 'https://github.com/kawahiro311'

  Rails.configuration.to_prepare do
    require_dependency 'idobata/hook_listener'
  end

  settings :default => {
    'idobata_webhook_url' => ''
  }, :partial => 'settings/idobata_settings'
end
