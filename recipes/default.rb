include_recipe "runit"

name = 'sidekiq_agent'
version = node['newrelic_sidekiq_agent']['version']
install_root = node['newrelic_sidekiq_agent']['install_root']
user = node['newrelic_sidekiq_agent']['user']
bundle_command = "/usr/local/rvm/bin/#{name}_bundle"

git install_root do
  repository node['newrelic_sidekiq_agent']['repository']
  revision version
  user user
end

template "#{install_root}/config/newrelic_plugin.yml" do
  source "newrelic_plugin.yml.erb"
  user node['newrelic_sidekiq_agent']['user']
  mode '0644'
end

execute 'bundle install' do
  cwd install_root
  user user
end

runit_service name do
  subscribes :restart, resources("application[sidekiq_agent]"), :delayed
  subscribes :restart, resources("template[#{install_root}/shared/config/newrelic_plugin.yml]"), :delayed
end
