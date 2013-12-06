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

    arguments "<kind>"

    when_invoked do |kind, options|
      
      valid_kinds = ['servers', 'images', 'flavors', 'zones']

      if valid_kinds.include?(kind) 
        cloudstack = Puppet::CloudPack::CloudStack.new(options)
        options[:kind] = kind
        servers = cloudstack.send(:"list_#{kind}");
      else
        raise ArgumentError, "Invalid search type, kind must be one of [flavors, images, or servers]"
      end
    end

    when_rendering :console do |return_value|
      case return_value[:kind] 
      when 'servers'
         return_value[:servers].map do |server|
           "#{server[:id]}:\n" <<
           "  name:         #{server[:name]}\n" <<
           "  displayname:  #{server[:display_name]}\n" <<
           "  state:        #{server[:state]}\n" 
         end.sort.join("\n")
       when 'images'
         return_value[:images]["listtemplatesresponse"]["template"].map do |image|
           "#{image['id']}:\n" <<
           "  name:          #{image['name']}\n" <<
           "  displaytext: #{image['displaytext']}\n" <<
           "  created:     #{image['created']}\n"
         end.sort.join("\n")
       when 'zones'
         return_value[:zones].map do |zone|
           "#{zone[:id]}:\n" <<
           "  name:         #{zone[:name]}\n" 
         end.sort.join("\n")
       when 'flavors'
         return_value[:flavors].map do |flavor|
           "#{flavor[:id]}:\n" <<
           "  name:          #{flavor[:name]}\n" <<
           "  cpu#:          #{flavor[:cpu_number]}\n" <<
           "  cpu speed:     #{flavor[:cpu_speed]}\n" <<
           "  memory:        #{flavor[:memory]}\n"
         end.sort.join("\n")

       end
       
    end

    returns 'Array of attribute hashes containing information about each EC2 instance.'

    examples <<-'EOT'
      List every instance in the US East region:

          $ puppet node_cloudstack list 
             025350d9-cd09-407c-935d-4f68d1ab6940:
             id: 025350d9-cd09-407c-935d-4f68d1ab6940
             keyname: mykey
             state: Stopped
    EOT
  end
end
