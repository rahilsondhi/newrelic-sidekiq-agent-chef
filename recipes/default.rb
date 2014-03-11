include_recipe "yum-epel"
include_recipe "rvm::system_install"
include_recipe "runit"

name = 'sidekiq_agent'

version = node['newrelic_sidekiq_agent']['version']
install_root = node['newrelic_sidekiq_agent']['install_root']
user = node['newrelic_sidekiq_agent']['user']

user user do
  supports :manage_home => true
  home node['newrelic_sidekiq_agent']['user_home']
  system true
end

# create rvm bundle wrapper for use in deployment
rvm_wrapper name do
  ruby_string   node['newrelic_sidekiq_agent']['rvm_ruby']
  binary        "bundle"
end

bundle_command = "/usr/local/rvm/bin/#{name}_bundle"

directory "#{install_root}/shared/config" do
  recursive true
  owner user
end

instances = node['newrelic_sidekiq_agent']['instances'].dup

instances.each do |instance|

  instance['instance_name'] ||= 'Redis Instance'
  instance['host'] ||= 'localhost'
  instance['port'] ||= '6379'

  redis_uri = 'redis://'

  if instance['password']
    redis_uri << URI.encode_www_form_component(instance['username']) + ":" + URI.encode_www_form_component(instance['password']) + "@"
  end

  redis_uri << "#{instance['host']}:#{instance['port']}"

  if instance['db']
    redis_uri << "/" + instance['db']
  end

  instance['redis_uri'] = redis_uri
end

template "#{install_root}/shared/config/newrelic_plugin.yml" do
  source "newrelic_plugin.yml.erb"
  user node['newrelic_sidekiq_agent']['user']
  mode '0644'
  variables(
    :instances => instances
  )
end

application name do
  repository node['newrelic_sidekiq_agent']['repository']
  revision version
  owner user
  path install_root
  # action 'force_deploy'
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
