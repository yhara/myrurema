require 'optparse'
require 'pathname'
require 'shellwords'
require 'tmpdir'

class Pathname; alias / +; end

class Options
  def initialize(argv)
    @command = nil
    @open_browser = false
    @port = nil
    @dry_run = false
    @no_ask = false
    @ruremadir = Pathname("~/.rurema").expand_path
    @rubyver = RUBY_VERSION

    @optionparser = OptionParser.new{|o|
      o.banner = [
        "Usage: rurema [options] <method name or class name>",
      ].join("\n")

      o.on("--init",
           "initialize rurema system"){
        @command = :init
      }
      o.on("--update",
           "update documents and database"){
        @command = :update
      }
      o.on("--server",
           "start web server"){
        @command = :server 
      }
      o.on("--preview",
           "render a reference as HTML"){
        @command = :preview 
      }
      o.on("--list",
           "list all classes"){
        @command = :list 
      }

      o.on("---- (OPTIONS)"){}

      o.on("--port=N",
           "port number of the web browser (only meaningful with --server)"){|n|
        @port = n.to_i
      }
      o.on("--browser",
           "open web browser (only meaningful with --server or --preview)"){
        @open_browser = true 
      }
      o.on("--dry-run",
           "show commands only"){
        @dry_run = true 
      }
      o.on("--no-ask",
           "do not ask keyboard input"){
        @no_ask = true 
      }
      o.on("--ruremadir=PATH",
           "specify rurema directory (default: #{@ruremadir})"){|path|
        @ruremadir = Pathname(path)
      }
      o.on("--rubyver=STR",
           "specify Ruby version (default: #{@rubyver})"){|str|
        @rubyver = str
      }

      o.on("----- (INFO)"){}

      o.on("--version",
           "show version of myrurema"){
        puts MyRurema::VERSION
        exit
      }
      o.on("--help",
           "show this message"){
        puts o
        exit
      }
    }
    @rest_args = @optionparser.parse(argv)
  end
  attr_accessor :dry_run, :no_ask, :ruremadir, :rubyver,
                :open_browser, :command, :port, :rest_args

  def ruremadir=(dir)
    @ruremadir = Pathname(dir)
  end

  def usage
    puts @optionparser
  end
end

class MyRurema
  VERSION = File.read((Pathname(__FILE__).dirname/"../VERSION").expand_path)
  SVN_URL = "http://jp.rubyist.net/svn/rurema" 

  def initialize(opt=Options.new(ARGV))
    @opt = opt
  end

  def run
    if @opt.command
      send(@opt.command)
    else
      query, num = *@opt.rest_args
      case
      when query && num
        search_num(query, num.to_i, @opt.rubyver)
      when query
        search(query, @opt.rubyver)
      else
        @opt.usage
      end
    end
  end

  def init
    sh "svn co -rHEAD #{SVN_URL}/doctree/trunk #{doctree_path}"
    sh "svn co -rHEAD #{SVN_URL}/bitclust/trunk #{bitclust_path}"
    init_db(@opt.rubyver)
  end

  def update
    sh "svn up #{doctree_path}"
    refresh_db(@opt.rubyver)
  end

  def search(query, ver)
    should_have_db(ver)

    cmd = "#{bitclust_path/'bin/refe'}" +
            " #{Shellwords.escape query} -d #{db_path(ver)}"
    sh cmd, :silent => true do |txt|
      if txt.lines.count < 10 and
         txt.lines.first(2).join =~ /#{query}.*#{query}/m and
         !@opt.no_ask

        words = {}
        k = 0
        puts txt.lines.map{|line|
          line.gsub(/(\S+)/){|str|
            k+=1
            words[k] = str
            "(#{k})#{str}"
          }
        }
        print "which one? > "
        line = $stdin.gets or (puts; exit)
        n = line.to_i

        puts "searching #{words[n]}"
        puts
        search(words[n].sub(/\.#/, "."), ver)
      else
        puts txt
      end
    end
  end

  def search_num(query, num, ver)
    should_have_db(ver)

    result = `#{bitclust_path/'bin/refe'} #{query} -d #{db_path(ver)}`
    word = result.split[num-1]
    if word
      word.gsub!(/\.#/, ".")    # avoid multi-hit for a module function
      puts "searching #{word}"
      search(word, ver)
    else
      error "less than #{num} entries found"
    end
  end

  def list
    should_have_db(@opt.rubyver)

    sh "#{bitclust_path/'bin/refe'}" +
         " -l -d #{db_path(@opt.rubyver)}", :silent => true
  end

  def server
    port = @opt.port || default_port(@opt.rubyver)
    th = Thread.new{
      sh "#{bitclust_path/'standalone.rb'}" +
           " --baseurl=http://localhost:#{port}" +
           " --port=#{port}" +
           " --database=#{db_path(@opt.rubyver)}" +
           " --debug"
    }
    if @opt.open_browser
      sleep 1  # wait for the server to start
      cmd = (/mswin/ =~ RUBY_PLATFORM) ? "start" : "open"
      sh "#{cmd} http://localhost:#{port}/view/"
    end
    th.join
  end

  TMP_FILE = Pathname(Dir.tmpdir)/'rurema_preview.html'
  def preview
    file, target = *@opt.rest_args

    if file
      error "file not found: #{file}" unless File.exist?(file)

      result = sh "#{bitclust_path/'tools/bc-tohtml.rb'}" +
                    " #{file}" +
                    (target ? " --target=#{target}" : "") +
                    " --ruby=#{@opt.rubyver}" +
                    " > #{TMP_FILE}"

      if result && @opt.open_browser
        cmd = (/mswin/ =~ RUBY_PLATFORM) ? "start" : "open"
        sh "#{cmd} #{TMP_FILE}"
      end
    else
      sh "cd #{doctree_path/'refm/api/src'}"
    end
  end
  
  private

  def default_port(ver)
    "10" + ver.scan(/\d/).join
  end

  def init_db(ver)
    sh "#{bitclust_path/'bin/bitclust'}" +
          " -d #{db_path(ver)} init version=#{ver} encoding=euc-jp"

    refresh_db(ver)
  end

  def refresh_db(ver)
    puts "Updating Rurema database:"
    puts "This will take a few minutes. Please be patient."
    sh "#{bitclust_path/'bin/bitclust'}" +
          " -d #{db_path(ver)}" +
          " update --stdlibtree=#{doctree_path/'refm/api/src'}"
  end

  def bitclust_path
    @opt.ruremadir / "bitclust"
  end

  def doctree_path
    @opt.ruremadir / "doctree"
  end

  def should_have_db(ver)
    unless has_db?(ver)
      puts "You don't have a database for ruby #{ver}."
      puts "Make it now? [y/n]"
      if $stdin.gets.chomp.downcase == "y"
        init_db(ver)
      else
        exit
      end
    end
  end

  def has_db?(ver)
    db_path(ver).directory?
  end

  def db_path(ver)
    @opt.ruremadir / "db" / ver
  end

  def sh(cmd, opt={}, &block)
    puts cmd unless opt[:silent]
    return if @opt.dry_run

    if block
      block.call(`#{cmd}`)
    else
      system cmd
    end
  end

  def error(msg)
    $stderr.puts msg unless $MYRUREMA_TEST
    exit
  end

  def puts(str)
    Kernel.puts(str) unless $MYRUREMA_TEST
  end
end
