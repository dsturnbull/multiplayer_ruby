require 'tempfile'

@@temp = Tempfile.new('sirb_cli')
@@temp << "# vim:filetype=ruby\n\n"
@@temp.read
@@temp = @@temp.path

def vi(file=nil)
  edit = Proc.new { |file| system("/usr/bin/env vim #{file}") }
  file = @@temp unless file
  edit.call(file)
  File.read(file)
end

if $0 == __FILE__
  puts vi
  vi 'sirb.rb'
end
