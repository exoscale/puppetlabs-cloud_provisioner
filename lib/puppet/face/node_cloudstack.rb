require 'puppet/face'

Puppet::Face.define(:node_cloudstack, '0.0.1') do
  copyright "Puppet Labs", 2011 .. 2013
  license   "Apache 2 license; see COPYING"

  summary "View and manage CloudStack based nodes."
  description <<-'EOT'
    This subcommand provides a command line interface to work with CloudStack
    machine instances.  The goal of these actions is to easily create new
    machines, install Puppet onto them, and tear them down when they're no longer
    required.
  EOT
end
