# encoding: utf-8

set :config_files, %w(database.yml environments/production.rb thin.yml)

namespace :deploy do
  desc "Create deploy directories, and change permissions"
  task :initial_setup, :roles => :app do
    try_sudo "mkdir -p #{shared_path}/config/environments"
    try_sudo "mkdir -p #{shared_path}/log"
    try_sudo "mkdir -p #{shared_path}/tmp"
    try_sudo "chmod -R g+w #{deploy_to}"
    try_sudo "chgrp -R #{sudo_group} #{deploy_to}"
    upload_config_files
  end

  desc "Upload local-config-files to server."
  task :upload_config_files, :roles => :app do
    config_files.each do |file|
      top.upload("config/shared/config/#{stage}/#{file}", "#{shared_path}/config/#{file}")
    end
  end

  task :finalize, :roles => :app do
    copy_config_files_to_current
    create_additional_symlinks
  end

  desc "Copy config files to relase-path"
  task :copy_config_files_to_current, :roles => :app do
    config_files.each do |file|
      try_sudo "cp #{shared_path}/config/#{file} #{release_path}/config/#{file}"
    end
  end

  desc "Create additional symlinks to shared-path"
  task :create_additional_symlinks, :roles => :app do
    try_sudo "rm -rf #{release_path}/log"
    try_sudo "ln -s #{shared_path}/log #{release_path}/log"

    try_sudo "rm -rf #{release_path}/tmp"
    try_sudo "ln -s #{shared_path}/tmp #{release_path}/tmp"
  end

  after "deploy:setup", "deploy:initial_setup"
  after "deploy:update_code", "deploy:finalize"
end
