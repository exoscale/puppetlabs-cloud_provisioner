require 'puppet/cloudpack'
require 'puppet/cloudpack/cloudstack'
require 'puppet/face/node_cloudstack'

Puppet::Face.define :node_cloudstack, '0.0.1' do
  action :create do
    summary 'Create a new Cloudstack nstance.'
    description <<-EOT
      This action launches a new Cloudstack instance and returns the public
      DNS name suitable for SSH access.

      A newly created system may not be immediately ready after launch while
      it boots. You can use the `fingerprint` action to wait for the system to
      become ready after launch.

      If creation of the instance fails, Puppet will automatically clean up
      after itself and tear down the instance.
    EOT

    option '--image-id=', '-i=' do
      summary "Template id"
      description <<-EOT
        Template id
      EOT
      required
      # TODO: Add before to check if valid id
    end

    option '--zone-id=','-z=' do
      summary "Zode id"
      description <<-EOT
        Zone id
      EOT
      required
      # TODO: Add before to check if valid id
    end

    option '--flavor-id=', '-f=' do
      summary "Flavor id"
      description <<-EOT
        Flavor id
      EOT
      required
      # TODO: Check if valid id
    end 
      
       
    when_invoked do |options|
      cloudstack = Puppet::CloudPack::CloudStack.new(options)
      cloudstack.create(options)
    end

    when_rendering :console do |value|
      puts value
    end
  end
end
