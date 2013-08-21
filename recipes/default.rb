#
# Cookbook Name:: chef-drupal-kickstart-lamp
# Recipe:: default

include_recipe "apt"

include_recipe "database"
include_recipe "database::mysql"
include_recipe "mysql::server"
include_recipe "mysql::client"

include_recipe "apache2"
include_recipe "apache2::mod_expires"
include_recipe "apache2::mod_php5"
include_recipe "apache2::mod_rewrite"

include_recipe "php"
php5_modules = ['curl', 'gd', 'mysql']
php5_modules.each do |mod|
  package "php5-" + mod do
    action :install
  end
end
package "php-apc"

#include_recipe "imagemagick"

package "drush"


# mysql connection
mysql_connection_info = {:host => "localhost",
                         :username => 'root',
                         :password => node['mysql']['server_root_password']}

# create a mysql database
mysql_database node['chef-drupal-kickstart-lamp']['db']['name'] do
  connection mysql_connection_info
  action :create
end

# make the mysql user
mysql_database_user node['chef-drupal-kickstart-lamp']['db']['user'] do
  connection mysql_connection_info
  password node['chef-drupal-kickstart-lamp']['db']['pass']
  database_name node['chef-drupal-kickstart-lamp']['db']['name']
  privileges [:all]
  action :grant
end

# Install commerce kick start
bash "commercekickstart" do
  code <<-EOH
(rm -rf /var/www/)
(cd /tmp; wget http://ftp.drupal.org/files/projects/commerce_kickstart-#{node['chef-drupal-kickstart-lamp']['site']['version']}-core.tar.gz)
(cd /tmp; tar -xvf commerce_kickstart-#{node['chef-drupal-kickstart-lamp']['site']['version']}-core.tar.gz)
(cd /tmp; mv commerce_kickstart-#{node['chef-drupal-kickstart-lamp']['site']['version']} /var/www)
(touch /var/www/sites/default/settings.php; chmod 777 /var/www/sites/default/settings.php)
(cd /var/www; drush site-install commerce_kickstart --db-url=mysql://#{node['chef-drupal-kickstart-lamp']['db']['user']}:#{node['chef-drupal-kickstart-lamp']['db']['pass']}@localhost/#{node['chef-drupal-kickstart-lamp']['db']['name']} --site-name=#{node['chef-drupal-kickstart-lamp']['site']['name']} -y)
(chmod 444 /var/www/sites/default/settings.php)
(chmod 777 /var/www/sites/default/files -R)
  EOH
  not_if { File.exists?("/var/www/index.php") }
end


# Disable the default apache site
apache_site "default" do
  enable false
end

# Setting up our apache site
web_app "kickstarter" do
  server_name node['ipaddress']
  server_aliases [node['fqdn'], node["ipaddress"], "kickstarter", "kickstarter-chef"]
  docroot "/var/www"
  allow_override "all"
end
