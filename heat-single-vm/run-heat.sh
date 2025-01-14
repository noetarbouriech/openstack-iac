openstack --os-cloud do stack create -t deploy-vm-with-heat.yaml \
  --parameter image_name="CentOS-9" \
  --parameter flavor_name="m1.small" \
  --parameter vm_name="my-heat-vm" \
  --parameter key_pair="ssh pc" \
  --parameter sg_name="rousquille" \
  --parameter network_name="chipolata" \
  my-heat-stack
