#!/usr/bin/ruby

# == Synopsis 
#
# == Usage
#   -v, --version   Displays version
#   -h, --help      Displays help message
#   -a              Specify the accession to retrieve from the NR database
#   -f              Specify a file with a list of accesions (one per line) to retrieve     
#   -d              Specify an alternative directory with the compiled NR-PANDA BLAST database 
#
# == Author
#    Ntino Krampis


require 'optparse' 
require 'ostruct'
require 'date'

$VERBOSE=nil

class App
  VERSION = '0.0.1'
  USAGE = "
   This is a yank_panda script for returning the entries (header and sequence)
   from the NR BLAST database which is used in lieu of PANDA. It is essentially
   a wrapper for NCBI's fastacmd. 

     -v, --version   Displays version
     -h, --help      Displays help message
     -a              Specify the accession to retrieve from the NR database
     -f              Specify a file with a list of accesions (one per line) to retrieve     
     -d              Specify an alternative directory with the compiled NR-PANDA BLAST database 
  "

  attr_reader :options

  def initialize()

    @options = OpenStruct.new
    @acc = String.new 
    @acc_file = String.new 
    @db = String.new 

  end


  def run

    parse_options 

    if !fastacmd_exists?
           puts "\nfastacmd component does not exist. Please use lserver[1-4] to execute this script\n"
    elsif !@acc.eql? ''
	    if run_single? 
		puts "------------------------------------------------------------------------------------------------------------"
        	puts "Please specify the correct database including the file's prefix (i.e. /database/dir/nr for nr.00, nr.01 etc)" 
		puts "------------------------------------------------------------------------------------------------------------"
	    end
	     	    
    elsif !@acc_file.eql? ''
            if run_batch?
		puts "------------------------------------------------------------------------------------------------------------"
	        puts "Please specify the correct database including the file's prefix (i.e. database/dir/nr for nr.00, nr.01 etc)"
		puts "------------------------------------------------------------------------------------------------------------"
	    end
    end

  end
  
  protected
  
    def parse_options
      
      opts = OptionParser.new 
      opts.on('-v', '--version')    { output_version ; exit 0 }
      opts.on('-h', '--help')       { output_help; exit 0 }
      opts.on('-a ', '--accession')   { |accession| @acc = accession }
      opts.on('-d ', '--database' ) { |database| @db = database } 
      opts.on('-f ', '--file')       { |file| @acc_file = file }
            
      opts.parse! rescue output_help

    end

    def output_help
      output_version
      puts USAGE
    end
   
    def fastacmd_exists?
      system("which fastacmd > /dev/null 2>/dev/null")
      return false if $?.exitstatus == 127
      return true
    end

    
    def output_version
      puts "\n#{File.basename(__FILE__)} version #{VERSION}\n\n"
    end
   
    
    def run_batch?
      puts "Start at #{DateTime.now}\n\n" 

      if !@db.eql? ''
	  puts #{@acc_file} 
          system("fastacmd -i #{@acc_file} -d #{@db}")      
          return true if $?.exitstatus == 2
      else 
	  system("fastacmd -i #{@acc_file}") 
      end	       

      puts "\nFinished at #{DateTime.now}" 
      false
    end


    def run_single?
      puts "Start at #{DateTime.now}\n\n" 

      if !@db.eql? ''
          system("fastacmd -s #{@acc} -d #{@db}")      
          return true if $?.exitstatus == 2
      else 
	  system("fastacmd -s #{@acc}") 
      end	       

      puts "\nFinished at #{DateTime.now}" 
      false
    end


end


# Create and run the application
app = App.new()
app.run

