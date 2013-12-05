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

      before_action do |action, args, options|
        cloudstack = Puppet::CloudPack::CloudStack.new(options)
        if cloudstack.connection.images.get(options[:image_id]).nil?
         raise ArgumentError, "Unrecognized image id: #{options[:image_id]}"
        end
      end

    end

    option '--zone-id=','-z=' do
      summary "Zode id"
      description <<-EOT
        Zone id
      EOT
      required
      
      before_action do |action, args, options|
        if Puppet::CloudPack::CloudStack.new(options).connection.zones.get(options[:zone_id]).nil?
          raise ArgumentError, "Unrecognized zone id: #{options[:zone_id]}"
        end
      end
    end

    option '--flavor-id=', '-f=' do
      summary "Flavor id"
      description <<-EOT
        Flavor id
      EOT
      required
     
      before_action do |action, args, options|
        if Puppet::CloudPack::CloudStack.new(options).connection.flavors.get(options[:flavor_id]).nil?
          raise ArgumentError, "Unrecognized flavor id: #{options[:flavor_id]}"
        end
      end
      
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
