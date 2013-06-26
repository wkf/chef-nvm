#
# Cookbook Name:: nvm
# Recipe:: system
#
# Copyright 2012, action.io
#
# All rights reserved - Do Not Redistribute
#

package 'git-core'

execute "install-nvm" do
  command <<-SHELL
if [ ! -d /usr/local/nvm ]
  then
    git clone git://github.com/creationix/nvm.git /usr/local/nvm
    groupadd nvm
    chown :nvm /usr/local/nvm
    chmod 775 /usr/local/nvm
    chmod g+s /usr/local/nvm
fi

if [ ! -d /etc/profile.d/nvm.sh ]
  then
    touch /etc/profile.d/nvm.sh
    echo '\n\n. /usr/local/nvm/nvm.sh\n' >> /etc/profile.d/nvm.sh
    . /usr/local/nvm/nvm.sh
fi
  SHELL

  notifies :run, "execute[install-nodes]", :immediately
  not_if "test -d /usr/local/.nvm"
end


execute "install-nodes" do
  @nodes = (Array(node['nvm']['nodes']) + [node['nvm']['default_node']]).uniq

  command @nodes.map { |n| "sudo -i nvm install #{n}" }.join("\n").strip

  if node['nvm']['default_node'] || @nodes.count > 0
    notifies :run, "execute[set-default-node]", :immediately
  end

  action :nothing
end

execute "set-default-node" do
  @default_node = node['nvm']['default_node'] || Array(node['nvm']['nodes']).first

  command "sudo -i nvm alias default #{@default_node}"

  action :nothing
end
