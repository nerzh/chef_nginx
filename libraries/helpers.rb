module ChefNginxHelper

  def self.included(klass)
    klass.include Repo
  end
  
  def ppa_repo_exist?
    `bash -lc 'apt-cache policy nginx'` != ''
  end

  module Repo
    def get_repo
      case node['platform']
      when 'debian'
        debian(node['platform_version'].to_i)
      when 'ubuntu'
        debian(node['platform_version'].to_i)
      end
    end

    def debian(version)
      case version
      when 6
        make_string('squeeze')
      when 7
        make_string('wheezy')
      when 8
        make_string('jessie')
      when 9
        make_string('stretch')
      else
        make_string('stretch')
      end
    end

    def ubuntu(version)
      case version
      when 14
        make_string('trusty')
      when 16
        make_string('xenial')
      when 17
        make_string('zesty')
      else
        make_string('zesty')
      end
    end

    def make_string(name)
      "\ndeb http://nginx.org/packages/debian/ #{name} nginx\ndeb-src http://nginx.org/packages/debian/ #{name} nginx\n"
    end

    def repo_exist?
      `bash -lc 'grep http://nginx.org /etc/apt/sources.list'` != ''
    end
  end

  def nginx_exist?
    `bash -lc 'which nginx'` != ''
  end
end