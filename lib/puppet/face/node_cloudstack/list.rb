require 'puppet/cloudpack'
require 'puppet/cloudpack/cloudstack'
require 'puppet/face/node_cloudstack'

Puppet::Face.define :node_cloudstack, '0.0.1' do
  action :list do

    summary 'List Cloudstack machine instances.'

    description <<-'EOT'
      This action obtains a list of instances from the cloud provider and
      displays them on the console output.
    EOT

    Puppet::CloudPack::Cloudstack.options(self, :provider)

    when_invoked do |options|
      connection = Puppet::CloudPack.create_connection(options)
      servers = connection.servers
      # Convert the Fog object into a simple hash.
      # And return the array to the Faces API for rendering
      hsh = {}
      servers.each do |s|
        hsh[s.id] = {
          "id"         => s.id,
          "state"      => s.state,
          "keyname"    => s.key_name,
        }
      end
      hsh
    end

    when_rendering :console do |value|
      value.collect do |id,status_hash|
        "#{id}:\n" + status_hash.collect do |field, val|
          "  #{field}: #{val}"
        end.sort.join("\n")
      end.sort.join("\n")
    end

    returns 'Array of attribute hashes containing information about each EC2 instance.'

    examples <<-'EOT'
      List every instance in the US East region:

          $ puppet node_aws list --region=us-east-1
          i-e8e04588:
            created_at: Tue Sep 13 01:21:16 UTC 2011
            dns_name: ec2-184-72-85-208.compute-1.amazonaws.com
            id: i-e8e04588
            state: running
    EOT

  end
end
