require_relative '../libraries/helpers'

actions :install
default_action :install

property :name,    String,             name_attribute: true
property :version, [String, NilClass], default: nil

action :install do
  break if nginx_exist?

  package 'nginx' do
    version new_resource.version if new_resource.version
    action :install
  end

  execute "restart NGINX" do
    user 'root'
    command %q(bash -lc "service nginx restart")
  end
end

action_class do
  include ChefNginxHelper
end