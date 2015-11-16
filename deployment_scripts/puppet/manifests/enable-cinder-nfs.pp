notice('MODULAR: enable-cinder-nfs.pp')


$nfs_network         = hiera('storage_network_range')
$fuel_plugin_nfs_mm1 = hiera_hash('fuel-plugin-nfs-mm1')
$network_metadata = hiera_hash('network_metadata')
$nfs_map             = get_node_to_ipaddr_map_by_network_role(get_nodes_hash_by_roles($network_metadata, ['fuel-plugin-nfs-mm1']), 'storage')


class enable_cinder_nfs(
   $volume_dir       = '/volume', 
   $shares_config    = '/etc/cinder/nfs_shares',
   $packages         = ['nfs-common', 'cinder-volume'],
   $network_metadata = hiera_hash('network_metadata'),
   $nfs_ip           = values($nfs_map),

) {
  notice('enable_cinder_nfs')
  package {$packages:
     ensure => present,
     before => File['/etc/cinder/nfs_shares']
   }

  cinder_config {
    'DEFAULT/volume_driver': value => 'cinder.volume.drivers.nfs.NfsDriver';
    'DEFAULT/nfs_shares_config': value => "$shares_config";
  }

   file {"$shares_config":
     ensure => present,
     content => "${nfs_ip}:${volume_dir}"
   }

   service {"cinder-volume":
     ensure => running
   }

  Cinder_config <||> -> File["$shares_config"] ~> Service['cinder-volume']

}


class { enable_cinder_nfs: 
  volume_dir    => $fuel_plugin_nfs_mm1["nfs-share-name"],
}