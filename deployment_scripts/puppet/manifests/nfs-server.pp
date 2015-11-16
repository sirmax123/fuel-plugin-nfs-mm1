notice('MODULAR: nfs-server.pp')



$nfs_network = hiera('storage_network_range')
$fuel_plugin_nfs_mm1=hiera_hash('fuel-plugin-nfs-mm1')


class nfs_server (
  $nfs_clients_network = $nfs_network,
  $nfs_data_folder     = '/data_folder1',
  $nfs_port            =  2049,
){
  file { $nfs_data_folder:
    ensure => 'directory',
  } ->

  class { '::nfs':
    server_enabled => true
   } ->

  nfs::server::export{ $nfs_data_folder:
    ensure  => 'present',
#    clients => "$nfs_clients_network(rw,insecure,async,no_root_squash) localhost(rw)"
    clients => "$nfs_clients_network(rw,insecure,async,anonuid=0,anongid=0,all_squash) localhost(rw)"
  } ->

  firewall { "000-nfs-plugin accept all nfs requests":
    proto  => 'tcp',
    port   => [$nfs_port],
    source => $nfs_clients_network,
    action => 'accept',
  }


}
class { nfs_server:
  nfs_clients_network => $nfs_network,
  nfs_data_folder     => $fuel_plugin_nfs_mm1["nfs-share-name"],
}

