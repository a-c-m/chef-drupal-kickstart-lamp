name             'chef-drupal-kickstart-lamp'
maintainer       'Alex McFadyen'
maintainer_email 'alex+chef-drupal-kickstart-lamp@acmconsulting.eu'
license          'MIT'
description      'Installs/Configures a commerce kickstart demo'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.1.0'

depends "apache2"
depends "database"
depends "php"
