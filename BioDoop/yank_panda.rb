#!/usr/bin/ruby

# == Synopsis 
#
# == Usage
#   -v, --version   Displays version
#   -h, --help      Displays help message
#   -a              Specify the accession to retrieve from the NR database
#   -f              Specify a file with a list of accesions (one per line) to retrieve     
#   -d              Specify an alternative directory with the compiled NR-PandA BLAST database 
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
   from the NR BLAST database which is used in lieu of PandA. It is essentially
   a wrapper for NCBI's cdbyank. 

     -v, --version     Displays version
     -h, --help        Displays help message
     -a, --accession   Specify a single accession to retrieve from the database (provide in the -a 'RF\|XP_642131.1' format)
     -f, --accessions  Specify a file with a list of accesions for batch retrieval (one per line, each written as RF|XP_642131 )
     -o, --output      Specify an output file to write the results 
     -r, --remove      If the output file exists, delete it (with only the -o option, the resuls will be appended to an existing file)
     -u, --uniref100   Search the Uniref100 derived PandA database (default: /usr/local/projects/DB/uniref100/uniref100_current/uniref100.fasta.cidx) 
     -n, --nr-panda    Search the NR derived PandA database (default: /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr.fasta.cidx)
     -d, --database    Specify an alternative directory containing the database (must contain .idx files, see note below)


   Note: This program is based on the indexes created by 'cdbfasta -C db.fasta', and are located 
   in the same directory as the BLAST database with the db.fasta.cidx extension.
  "

  attr_reader :options

  def initialize()

    @options = OpenStruct.new
    @acc = String.new 
    @acc_file = String.new 
    @output_file = String.new 
    @uniref = FALSE
    @nr = FALSE
    @db = String.new 
    @file = nil

  end


  def run

    parse_options 

    if !cdbyank_exists?
           puts "\ncdbfasta/cdbyank programs do not exist. Please use lserver[1-4] or hermes to execute this script\n"
	   exit 0
    elsif !output_path_exists?
           puts "------------------------------------------------------------------------------------------------------------"
           puts "\n*** Please specify correctly the directory path or name for the output file (with the -o option) and re-run this program ***\n\n" 
           puts "------------------------------------------------------------------------------------------------------------"
           puts USAGE
	   exit 0
    elsif !@nr and !@uniref and @db.eql? ''
           puts "------------------------------------------------------------------------------------------------------------"
           puts "\n*** Please specify NR-PandA (-n), or Uniref100-PandA(-u), or custom index (-d) directory and re-run this program ***\n\n" 
           puts "------------------------------------------------------------------------------------------------------------"
           puts USAGE
	   exit 0
    elsif @acc.eql? '' and @acc_file.eql? ''
           puts "------------------------------------------------------------------------------------------------------------"
           puts "\n*** Please specify a single accession (-a option) or a file contain a list of accessions (-f option) ***\n\n" 
           puts "------------------------------------------------------------------------------------------------------------"
           puts USAGE
	   exit 0
    elsif !@acc.eql? ''
	    if run_single? 
		puts "------------------------------------------------------------------------------------------------------------"
        	puts "\n*** Could not find the index file specified with the '-d' option.***\n\n" 
		puts "------------------------------------------------------------------------------------------------------------"
	    end
	   exit 0
    elsif !@acc_file.eql? '' and batch_file_exists? 
		puts "------------------------------------------------------------------------------------------------------------"
        	puts "\n*** Could not find the file containing the list of accessions specified with the '-f' option.***\n\n" 
		puts "------------------------------------------------------------------------------------------------------------"
	   exit 0
    elsif !@acc_file.eql? '' and !batch_file_exists?
            if run_batch?
		puts "------------------------------------------------------------------------------------------------------------"
        	puts "\n*** Could not find the index file specified with the '-d' option.***\n\n" 
		puts "------------------------------------------------------------------------------------------------------------"
	    end
	   exit 0
    end

  end
  
  protected
  
    def parse_options
      
      opts = OptionParser.new 
      opts.on('-v', '--version')      { output_version ; exit 0 }
      opts.on('-h', '--help')         { output_help; exit 0 }
      opts.on('-a ', '--accession')   { |accession| @acc = accession }
      opts.on('-f ', '--accessions')  { |accessions| @acc_file = accessions }
      opts.on('-o ', '--output')      { |output| @output_file = output }
      opts.on('-r', '--remove')       { |delete| @delete_file = delete }
      opts.on('-u', '--uniref100')    { @uniref = TRUE  }
      opts.on('-n', '--nr-panda')     { @nr = TRUE }
      opts.on('-d ', '--database')    { |database| @db = database } 
            
      opts.parse! rescue output_help

    end


    def output_help
      output_version
      puts USAGE
    end

   
    def output_version
      puts "\n#{File.basename(__FILE__)} version #{VERSION}\n\n"
    end


    def cdbyank_exists?
      system("which cdbyank > /dev/null 2>/dev/null")
      return false if $?.exitstatus == 127
      return true
    end


    def output_path_exists?
      return false if @output_file.eql? ''
      output_dir =  @output_file.gsub(/\/[A-Za-z]+$/,'')
      system("ls #{output_dir} > /dev/null 2>/dev/null")      
      return false if $?.exitstatus == 2
      return true 
    end


    def batch_file_exists?
      return false if @file = File.open(@acc_file)
      return true
    end


    def run_batch?
      puts "Start at #{DateTime.now}\n\n" 

      if @delete_file
	 system("rm #{@output_file}") 
      end

      if !@db.eql? ''
	  @file.each { |accession| 
	        accs = accession.split("|")
		accs.at(1).chomp!
		system("cdbyank #{@db} -a #{accs.at(0)}\\|#{accs.at(1)} >> #{@output_file} ")
                return true if $?.exitstatus == 2
		system("cdbyank #{@db} -a UniRef100_#{accs.at(0)} >> #{@output_file} ")
                return true if $?.exitstatus == 2
		}    
      elsif @uniref 
	  @file.each { |accession| 
		accession.chomp!
		system("cdbyank /usr/local/projects/DB/uniref100/uniref100_current/uniref100.fasta.cidx -a UniRef100_#{accession} >> #{@output_file} ")
                return true if $?.exitstatus == 2
		}    
      elsif @nr 
	  @file.each { |accession| 
	        accs = accession.split("|")
		accs.at(1).chomp!
	        system("cdbyank /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr-1.fasta.cidx -a #{accs.at(0)}\\|#{accs.at(1)} >> #{@output_file} ") 
                return true if $?.exitstatus == 2
	        system("cdbyank /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr-2.fasta.cidx -a #{accs.at(0)}\\|#{accs.at(1)} >> #{@output_file} ") 
                return true if $?.exitstatus == 2
	        system("cdbyank /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr-3.fasta.cidx -a #{accs.at(0)}\\|#{accs.at(1)} >> #{@output_file} ") 
                return true if $?.exitstatus == 2
		}    
      end	       

      puts "\nFinished at #{DateTime.now}" 
      false
    end

    def run_single?
      puts "Start at #{DateTime.now}\n\n" 
      
      if @delete_file
	 system("rm #{@output_file}") 
      end

      if !@db.eql? ''
          system("cdbyank #{@db} -a #{@acc} >> #{@output_file} ")      
          return true if $?.exitstatus == 2
      elsif @uniref 
	  system("cdbyank /usr/local/projects/DB/uniref100/uniref100_current/uniref100.fasta.cidx -a UniRef100_#{@acc} >> #{@output_file} ") 
          return true if $?.exitstatus == 2
      elsif @nr 
	  system("cdbyank /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr-1.fasta.cidx -a #{@acc} >> #{@output_file} ") 
          return true if $?.exitstatus == 2
	  system("cdbyank /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr-2.fasta.cidx -a #{@acc} >> #{@output_file} ") 
          return true if $?.exitstatus == 2
	  system("cdbyank /usr/local/projects/DB/NR-PANDA/NR-PANDA_current/panda-nr-3.fasta.cidx -a #{@acc} >> #{@output_file} ") 
          return true if $?.exitstatus == 2
      end	       

      puts "\nFinished at #{DateTime.now}" 
      false
    end


end


# Create and run the application
app = App.new()
app.run

