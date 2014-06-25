include_recipe "runit"

version = node['newrelic_sidekiq_agent']['version']
install_root = node['newrelic_sidekiq_agent']['install_root']
user = node['newrelic_sidekiq_agent']['user']

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

runit_service 'sidekiq_agent' do
  owner user
  sv_timeout 30
  action [:enable]
end
