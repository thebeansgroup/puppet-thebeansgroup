class thebeansgroup::config {
  require boxen::config
  
  $solrversion = "4.2.0-boxen1"
  $solrdir = "${boxen::config::homebrewdir}/Cellar/solr/${solrversion}"
  $solrcollectiondir = "${solrdir}/libexec/example/solr"
  notice($solrcollectiondir)
}
