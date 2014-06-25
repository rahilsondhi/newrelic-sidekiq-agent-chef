include_recipe "yum-epel"
include_recipe "rvm::system_install"
include_recipe "runit"

name = 'sidekiq_agent'

version = node['newrelic_sidekiq_agent']['version']
install_root = node['newrelic_sidekiq_agent']['install_root']
user = node['newrelic_sidekiq_agent']['user']

bundle_command = "/usr/local/rvm/bin/#{name}_bundle"

directory "#{install_root}/shared/config" do
  recursive true
  owner user
end

template "#{install_root}/shared/config/newrelic_plugin.yml" do
  source "newrelic_plugin.yml.erb"
  user node['newrelic_sidekiq_agent']['user']
  mode '0644'
end

application name do
  repository node['newrelic_sidekiq_agent']['repository']
  revision version
  owner user
  path install_root
  symlink_before_migrate(
    "config/newrelic_plugin.yml" => "config/newrelic_plugin.yml",
  )
  rails do
    bundler true
    bundle_command bundle_command
  end
end

runit_service name do
  subscribes :restart, resources("application[sidekiq_agent]"), :delayed
  subscribes :restart, resources("template[#{install_root}/shared/config/newrelic_plugin.yml]"), :delayed
end
