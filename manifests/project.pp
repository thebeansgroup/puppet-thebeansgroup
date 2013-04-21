# A Boxen-focused project setup helper with additions for the beans group.
# For more information please checkout:
#    https://github.com/boxen/puppet-boxen/blob/master/manifests/project.pp
#
# Options:
#
#     dir =>
#       The directory to clone the project to.
#       Defaults to "${boxen::config::srcdir}/${name}".
#
#     dotenv =>
#       If true, creates "${dir}/.env" from
#       "puppet:///modules/projects/${name}/dotenv".
#
#     elasticsearch =>
#       If true, ensures elasticsearch is installed.
#
#     memcached =>
#       If true, ensures memcached is installed.
#
#     mongodb =>
#       If true, ensures mongodb is installed.
#
#     mysql =>
#       If set to true, ensures mysql is installed and creates databases named
#       "${name}_development" and "${name}_test".
#       If set to any string or array value, creates those databases instead.
#
#     nginx =>
#       If true, ensures nginx is installed and uses standard template at
#       modules/projects/templates/shared/nginx.conf.erb.
#       If given a string, uses that template instead.
#
#     postgresql =>
#       If set to true, ensures postgresql is installed and creates databases
#       named "${name}_development" and "${name}_test".
#       If set to any string or array value, creates those databases instead.
#
#     redis =>
#       If true, ensures redis is installed.
#
#     ruby =>
#       If given a string, ensures that ruby version is installed.
#       Also creates "${dir}/.ruby-version" with content being this value.
#
#     source =>
#       Repo to clone project from. REQUIRED. Supports shorthand <user>/<repo>.
#

define thebeansgroup::project(
    $source        = undef,
    $dir           = undef,
    $dotenv        = undef,
    $elasticsearch = undef,
    $memcached     = undef,
    $mongodb       = undef,
    $mysql         = undef,
    $nginx         = undef,
    $nodejs        = undef,
    $postgresql    = undef,
    $redis         = undef,
    $ruby          = undef,
    $solr          = undef,
) {
  include thebeansgroup::config

  $repo_source = $source ? {
    undef   => "thebeansgroup/${name}",
    default => $source
  }

  $repo_dir = $dir ? {
    undef   => "${boxen::config::srcdir}/${name}",
    default => $dir
  }

  if $solr {
    include solr
    include solr::config
    file { "${solr::config::configdir}/${name}":
      ensure  => link,
      target  => "${boxen::config::srcdir}/${name}/config/solr",
      require => [ Package['boxen/brews/solr'], Repository[$repo_dir] ];
    }
    searchindex { $name:
      name       => $name,
      provider   => solr,
      configfile => $solr::config::solrconfig,
      notify     => Service['dev.apache.solr'],
      require    => Package['boxen/brews/solr'];
    }
  }

  boxen::project { $name:
    dir           => $dir,
    dotenv        => $dotenv,
    elasticsearch => $elasticsearch,
    memcached     => $memcached,
    mongodb       => $mongodb,
    mysql         => $mysql,
    nginx         => $nginx,
    nodejs        => $nodejs,
    postgresql    => $postgresql,
    redis         => $redis,
    ruby          => $ruby,
    source        => $repo_source,
  }
}

