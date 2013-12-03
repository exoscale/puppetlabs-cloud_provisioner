require 'puppet/cloudpack'

# This is a container for various horrible procedural code used to set up the
# face actions for the `node_gce` face.  It lives here because the design of
# faces -- reinventing the Ruby object model, poorly -- makes it impossible to
# do standard things such as module inclusion, or inheritance, that would
# normally solve these problems in a real OO system.
module Puppet::CloudPack::Cloudstack
  module_function

  def options(to, *which)
    which.each do |name|
      send("add_#{name}_option", to)
    end
  end

  def add_zone_option(to, with_default = true)
    to.option '--zone CH2' do
      summary 'Limit to instances in the specified zone'
      with_default and default_to { 'CH2' }
    end
  end

  def add_provider_option(to, with_default = true)
    to.option '--provider Cloudstack' do
      summary 'Fog provider'
      with_default and default_to { 'Cloudstack' }
     end
  end

  def add_image_option(to)
    to.option '--image <name>' do
      summary 'Template to use to create the instance'
      description <<-EOT
          The pre-configured operating system image to use when creating this
          machine instance. 
      EOT
      required
      before_action do |action, args, options|
        if Puppet::CloudPack.create_connection(options).images.get(options[:image]).nil?
          raise ArgumentError, "Unrecognized image name: #{options[:image]}"
        end
      end
    end
  end
end
