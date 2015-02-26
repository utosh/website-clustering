# encoding: utf-8

namespace :deploy do
  task :start, :roles => :app, :except => { :no_release => true, :no_server => true }, :on_no_matching_servers => :continue do
    run <<-CMD.compact
      cd #{current_path} &&
      #{try_sudo} PATH=$PATH:#{binary_path} #{bundle_cmd} exec thin -c #{current_path} -e #{deploy_environment} -C config/thin.yml start
    CMD
  end

  task :stop, :roles => :app, :except => { :no_release => true, :no_server => true }, :on_no_matching_servers => :continue do
    run <<-CMD.compact
      cd #{current_path} &&
      #{try_sudo} PATH=$PATH:#{binary_path} #{bundle_cmd} exec thin -c #{current_path} -e #{deploy_environment} -C config/thin.yml stop
    CMD
  end

  task :restart, :roles => :app, :except => { :no_release => true, :no_server => true }, :on_no_matching_servers => :continue do
    stop
    start
  end
end
