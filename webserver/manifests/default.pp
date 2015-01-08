  exec { "apt-get update":
    command => "/usr/bin/apt-get update",
    onlyif => "/bin/sh -c '[ ! -f /var/cache/apt/pkgcache.bin ] || /usr/bin/find /etc/apt/* -cnewer /var/cache/apt/pkgcache.bin | /bin/grep . > /dev/null'",
  }
  package  {  "nginx":
    ensure => installed,
    require  => Exec['apt-get update']
  } 
  service { "nginx-ruuing":
    name => 'nginx',
    ensure => running,
    require  => Package["nginx"]
  }  
  file { "cert":
    ensure => directory,
    recurse => true,
    path => "/etc/nginx/ssl/",
    source => "/vagrant/webserver/certs/",
    require => Package["nginx"]
  }    
  file { "nginx.conf":
    path => "/etc/nginx/nginx.conf",
    source => "/vagrant/webserver/confs/nginx.conf",
    require => File["cert"]
  }  
  exec { 'reload nginx':
    command => '/etc/init.d/nginx reload',
    require => File["nginx.conf"]  
  }
  file {"index.html":
	  path => "/usr/share/nginx/www/index.html",
	  content => "<html><head><title>${hostname}</title></head><body><h1>${hostname}</h1></body></html>",
	  ensure => file,
    require => Package["nginx"]
  }
 
  # Required packages for development 
  class myDevelopmentEnv {
    package {'vim': ensure => 'present'}
    package {'mc': ensure => 'present'}
    package {'mongodb': ensure => 'present'}
  }
  
  # Apply it
  include myDevelopmentEnv
