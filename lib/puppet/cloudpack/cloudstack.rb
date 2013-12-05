require 'puppet/cloudpack'

# This is a container for various horrible procedural code used to set up the
# face actions for the `node_gce` face.  It lives here because the design of
# faces -- reinventing the Ruby object model, poorly -- makes it impossible to
# do standard things such as module inclusion, or inheritance, that would
# normally solve these problems in a real OO system.
module Puppet::CloudPack

  class CloudStack

    attr_accessor :connection

    def initialize(options, connection=nil)
      @options    = options
      @connection = connection || create_connection
    end

    def create_connection(options = {})
      connection = Fog::Compute[:Cloudstack]
    end

    def list
      servers = @connection.servers
      # Convert the Fog object into a simple hash.
      # And return the array to the Faces API for rendering
      if servers.empty?
        s = {}
      else
        s = servers.collect {|s| s.attributes}
      end
      s
    end

    def create(options)
      create_options = {
        :image_id      => options[:image_id],
        :flavor_id     => options[:flavor_id],
        :zone_id       => options[:zone_id],
      } 
      @connection.servers.create(create_options)
    end

  end
end
