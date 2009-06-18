require 'rubygems'
require 'readline'
require 'tempfile'
require File.dirname(__FILE__) + '/lib/vi'
require File.dirname(__FILE__) + '/lib/sirb/client'

# sirb(main):8D42> vi
# class A
#   def poo
#   end
# end
# :wq
# sirb(main):8D42> class A
#   def poo
#   end
# end
# =>nil
# sirb(main:8D42> vi t.rb
# class A
#   def poo
#   end
# end
# :wq
# ...
# sirb(main:8D42> vi t.rb
# :%s/A/B/g
# :wq
# sirb(main:8D42> B.new
# => <SIRB::B>
#

class SIRBCli
  def interpreter
    SIRBClient.set_history
    loop do
      cmd = nil
      prompt = SIRBClient.prompt
      line = Readline::readline(prompt)
      if line =~ /^vi$/
        cmd = vi
      elsif line =~ /^vi (.*)$/
        cmd = vi $1
      elsif line =~ /^lload '(.*)'/
        cmd = File.read($1)
      else
        cmd = line
      end
      exit(0) if line.nil?

      unless cmd.nil?
        puts SIRBClient.execute(:cmd => cmd)
      end
    end
  end
end

sirb = SIRBCli.new
sirb.interpreter

