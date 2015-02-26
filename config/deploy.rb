set :stage, %(production staging)
require "capistrano/ext/multistage"

# Bundle
set :binary_path,   "/usr/local/bin"
set :ruby_path,     "/usr/local/bin/ruby"
set :bundle_cmd,    "/usr/local/bin/bundle"
# set :bundle_flags,  "--quiet"#"--deployment --quiet"
set :bundle_roles, :app
require 'bundler/capistrano'

# SCM
set :scm, :git
set :scm_user, Proc.new { Capistrano::CLI.ui.ask('GIT User: ') }
set :scm_password, Proc.new { Capistrano::CLI.password_prompt('GIT Password: ') }
set :repository, lambda{ "https://#{scm_user}:#{scm_password}@#{repository_uri}" }

set :ssh_options, {auth_methods: nil}
default_run_options[:pty]=true

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

load "config/recipes/setup"
load "config/recipes/thin"

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :default, :roles => :app do
    update
    restart
    cleanup
  end

  # NOTICE: xargsでsudoのパスワードを聞かれる問題回避のため旧バージョンの処理でオーバーライド
  # capistrano v2.14.2 から
  desc <<-DESC
    Clean up old releases. By default, the last 5 releases are kept on each \
    server (though you can change this with the keep_releases variable). All \
    other deployed revisions are removed from the servers. By default, this \
    will use sudo to clean up the old releases, but if sudo is not available \
    for your environment, set the :use_sudo variable to false instead.
  DESC
  task :cleanup, :except => { :no_release => true } do
    count = fetch(:keep_releases, 5).to_i
    local_releases = capture("ls -xt #{releases_path}").split.reverse
    if count >= local_releases.length
      logger.important "no old releases to clean up"
    else
      logger.info "keeping #{count} of #{local_releases.length} deployed releases"
      directories = (local_releases - local_releases.last(count)).map { |release|
        File.join(releases_path, release) }.join(" ")

      try_sudo "rm -rf #{directories}"
    end
  end
end
