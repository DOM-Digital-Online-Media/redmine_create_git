require_dependency 'repository'

module CreateGit
  module RepositoryPatch
    def self.included(base)
      base.send(:include, InstanceMethods)
      base.instance_eval do
        before_destroy :remove_repository_from_disk
      end
    end

    module InstanceMethods
      private
        def remove_repository_from_disk
          git_bin = Redmine::Configuration['scm_git_command'] || "git"
          sys_repo_remove = Setting.plugin_redmine_create_git['sys_repo_remove']

          repo_fullpath = (self.root_url.blank? ? self.url : self.root_url)
          unless system ("#{sys_repo_remove} #{self.url} #{git_bin}")
            Rails.logger.error "Could not create Repository '#{repo_fullpath}'! Check your syslog."
            raise I18n.t('errors.repo_remove_fail', {:path => repo_fullpath})
            return false
          end
        end
    end
  end
end

Repository.send(:include, CreateGit::RepositoryPatch)