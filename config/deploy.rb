set :rvm_ruby_string, '1.9.3@paywithme'
set :rvm_type, :system

require "bundler/capistrano"
require "rvm/capistrano"
require "delayed/recipes"
require 'new_relic/recipes'

server "198.61.183.12", :web, :app, :db, primary: true

set :application, "PayWithMe"
set :user, "deployer"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, :false
set :rails_env, "production" # Added for delayed job  

set :scm, :git
set :repository,  "git@github.com:austingulati/PayWithMe.git"
set :branch, :master

default_run_options[:pty] = true
ssh_options[:forward_agent] = true

after "deploy", "deploy:cleanup" # keep only the last 5 releases

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "198.61.183.12"
# role :app, "198.61.183.12"
# role :db,  "1b12fd70c830cdcd93e85c87a895656a140c9d5d.rackspaceclouddb.com", :primary => true

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :setup_config, roles: :app do
    sudo "ln -nfs #{current_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    run "mkdir -p #{shared_path}/config"
    put File.read("config/database.example.yml"), "#{shared_path}/config/database.yml"
    puts "Now edit the config files in #{shared_path}."
  end
  after "deploy:setup", "deploy:setup_config"

  task :symlink_config, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "deploy:symlink_config"

  desc "Make sure local git is in sync with remote."
  task :check_revision, roles: :web do
    unless `git rev-parse HEAD` == `git rev-parse origin/master`
      puts "WARNING: HEAD is not the same as origin/master"
      puts "Run `git push` to sync changes."
      exit
    end
  end
  before "deploy", "deploy:check_revision"

  namespace :assets do
    task :precompile, :roles => :web, :except => { :no_release => true } do
      # Check if assets have changed. If not, don't run the precompile task - it takes a long time.
      force_compile = false
      changed_asset_count = 0
      begin
        from = source.next_revision(current_revision)
        asset_locations = 'app/assets/ lib/assets/ vendor/assets/'
        changed_asset_count = capture("cd #{latest_release} && #{source.local.log(from)} #{asset_locations} | wc -l").to_i
      rescue Exception => e
        logger.info "Error: #{e}, forcing precompile"
        force_compile = true
      end
      if changed_asset_count > 0 || force_compile
        logger.info "#{changed_asset_count} assets have changed. Pre-compiling"
        run_locally "rake assets:precompile"

        storage = Fog::Storage.new(provider: 'Rackspace', rackspace_api_key: Figaro.env.rackspace_key, rackspace_username: Figaro.env.rackspace_username, rackspace_storage_url: Figaro.env.rackspace_url)

        directory = storage.directories.get('static-assets')
        Dir.glob(File.join("public", "assets", "*")).each do |file|
          directory.files.create(key: File.join("assets", File.basename(file)), body: File.open(file)) unless File.directory?(file)
        end

        run_locally "rm -rf public/assets"
      else
        logger.info "#{changed_asset_count} assets have changed. Skipping asset pre-compilation"
      end
    end
  end

  # Delayed job
  after "deploy:stop",    "delayed_job:stop"
  after "deploy:start",   "delayed_job:start"
  after "deploy:restart", "delayed_job:restart"

  # New Relic RPM
  after "deploy:update", "newrelic:notice_deployment"
end