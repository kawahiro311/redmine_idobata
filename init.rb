Redmine::Plugin.register :redmine_idobata do
  name 'Redmine Idobata plugin'
  author 'Hiro Kawasaki'
  description 'Idobata.io chat integration'
  version '0.0.1'
  url 'https://github.com/kawahiro311/redmine_idobata'
  author_url 'https://github.com/kawahiro311'

  Rails.configuration.to_prepare do
    require_dependency 'idobata/hook_listener'
    require_dependency 'idobata/view_hooks'
    require_dependency 'idobata/project_patch'
    Project.send(:include, RedmineIdobata::Patches::ProjectPatch)
  end
end
