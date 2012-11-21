#!/usr/bin/ruby
require 'digest/sha1'

members = Array.new
seq = String.new
sha1 = String.new
accession = String.new

STDIN.each_line do |line|

   line.chomp!

   if line[0..0].eql? ">"
	members = line.split(/>/)
   else
	sha1 = Digest::SHA1.hexdigest(line)
	seq = line
   end

   members.each { |accession|

      if !seq.eql? "" && !accession.eql? ""
          puts "#{sha1}\t#{accession}---#{seq}"
	  seq = ""
      else
          puts "#{sha1}\t#{accession}"
      end

   }
 
end
