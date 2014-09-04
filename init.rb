require_dependency 'idobata/hook_listener'

Redmine::Plugin.register :redmine_idobata do
  name 'Redmine Idobata plugin'
  author 'Hiro Kawasaki'
  description 'Idobata.io chat integration'
  version '0.0.1'
  url 'https://github.com/kawahiro311/redmine_idobata'
  author_url 'https://github.com/kawahiro311'

  settings :default => {
    'idobata_webhook_url' => ''
  }, :partial => 'settings/idobata_settings'
end
