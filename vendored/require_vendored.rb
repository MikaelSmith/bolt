$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'puppet/lib'))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), 'hiera/lib'))

require 'puppet_pal'
