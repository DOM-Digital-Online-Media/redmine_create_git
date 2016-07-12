require 'redmine'


Rails.configuration.to_prepare do
  require_dependency 'create_git/projects_controller_patch'
  require_dependency 'create_git/repository_patch'
end


Redmine::Plugin.register :redmine_create_git do
  name 'Redmine Create Git plugin'
  author 'Martin DENIZET'
  url 'https://github.com/martin-denizet/redmine_create_git'
  author_url 'http://martin-denizet.com'
  description 'Ease the creation of Git repositories when using Git Smart HTTP'
  version '0.2.0'

  requires_redmine :version_or_higher => '2.0.0'

  settings :default => {
      :gitignore => '',
      :repo_path => File.expand_path('../repos/git/', Rails.root),
      :repo_url => '',
      :branches => '',
      :sys_repo_create => '',
      :sys_repo_remove => ''
  }, :partial => 'settings/create_git'

end
