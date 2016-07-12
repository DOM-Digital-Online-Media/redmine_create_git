class GitCreator
  GIT_BIN = Redmine::Configuration['scm_git_command'] || "git"

  def self.create_git(project, repo_identifier, is_default)
    repo_path_base = Setting.plugin_redmine_create_git['repo_path']
    repo_path_base += '/' unless repo_path_base[-1, 1]=='/'

    repo_url_base = Setting.plugin_redmine_create_git['repo_url']
    if (defined?(Checkout) and not repo_url_base.nil?)
      repo_url_base += '/' unless repo_url_base[-1, 1]=='/'
    end

    project_identifier = project.identifier

    new_repo_name = project_identifier
    new_repo_name += "-#{repo_identifier}" unless repo_identifier.empty?

    new_repo_path = repo_path_base + new_repo_name


    Rails.logger.info "Creating repo in #{new_repo_path} for project #{project.name}"

    if project and create_repo(new_repo_path)
      repo = Repository.factory('Git')
      repo.project = project
      repo.url = repo_path_base+new_repo_name
      repo.login = ''
      repo.password = ''
      repo.root_url = new_repo_path
      #If the checkout plugin is installed
      if (defined?(Checkout))
        #New checkout plugin configuration hash
        #TODO: Use Checkout plugin defaults
        repo.checkout_overwrite = '1'
        repo.checkout_display_command = Setting.send('checkout_display_command_Git')
        #Somehow it would not work using a simple Hash
        params = ActionController::Parameters.new({:checkout_protocols => [{
                                                                               'command' => "git clone",
                                                                               'is_default' => '1',
                                                                               'protocol' => 'Git',
                                                                               'fixed_url' => repo_url_base+new_repo_name,
                                                                               'access' => 'permission'}]
                                                  }) unless repo_url_base.nil?

        repo.checkout_protocols = params[:checkout_protocols] if params

      end
      #TODO: Use Redmine defaults
      repo.extra_info = {'extra_report_last_commit' => '0'}
      repo.identifier = repo_identifier
      repo.is_default = is_default
      return repo
    end

  end

  def self.create_repo(repo_fullpath)
    sys_repo_create = Setting.plugin_redmine_create_git['sys_repo_create']
    gitignore = Setting.plugin_redmine_create_git['gitignore']

    if not File.exist?(sys_repo_create)
      Rails.logger.error "no create utility found in #{sys_repo_create}"
      raise I18n.t('errors.repo_no_create_utility', {:path => sys_repo_create})
      return true
    end
    if File.exist?(repo_fullpath)
      Rails.logger.error "Repository in '#{repo_fullpath}' already exists!"
      raise I18n.t('errors.repo_already_exists', {:path => repo_fullpath})
      return true
    end
    unless system ("echo \"#{gitignore}\" | #{sys_repo_create} #{repo_fullpath} #{GIT_BIN}")
      Rails.logger.error "Could not create Repository '#{repo_fullpath}'! Check your syslog."
      raise I18n.t('errors.repo_create_fail', {:path => repo_fullpath})
      return false
    end
    Rails.logger.info 'Creation finished'
    return true
  end
end
