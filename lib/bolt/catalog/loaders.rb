# frozen_string_literal: true

module Puppet
  module Pops
    class BoltLoaders < Loaders
      def create_puppet_system_loader
        parent = super

        Puppet::Pops::Loader::ModuleLoaders::FileBased.new(
          parent,
          self,
          'boltlib',
          File.join(__dir__, '../../../bolt-modules/boltlib'),
          'boltlib_system'
        )
      end

      def pre_load
        super

        # Pre-populate Bolt datatypes
        @puppet_system_loader.load(:type, 'target')
        @puppet_system_loader.load(:type, 'result')
        @puppet_system_loader.load(:type, 'resultset')
      end
    end
  end
end
