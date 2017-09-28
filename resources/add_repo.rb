require_relative '../libraries/helpers'

actions :add
default_action :add

property :name,      String, name_attribute: true
# property :ppa,       String, required: true
property :keyserver, String, required: true

action :add do
  break if repo_exist?
  
  ruby_block "add nginx repo to /etc/apt/sources.list" do
    repo        = get_repo
    repo_regexp = /http:\/\/nginx\.org/

    block do
      file = Chef::Util::FileEdit.new('/etc/apt/sources.list')
      file.insert_line_if_no_match(repo_regexp, repo)
      file.write_file
    end
  end

  # break if ppa_repo_exist?
  # execute "add ppa nginx" do
  #   command "add-apt-repository ppa:#{new_resource.ppa}"
  # end

  execute "make trust repo - apt-key" do
    command "sudo apt-key adv --recv-keys --keyserver #{new_resource.keyserver} `sudo apt-get update 2>&1 | grep -o '[0-9A-Z]\\{16\\}$' | xargs`"
  end

  apt_update 'update'
end

action_class do
  include ChefNginxHelper
end