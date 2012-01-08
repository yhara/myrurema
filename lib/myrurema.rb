require 'optparse'
require 'pathname'
require 'shellwords'
require 'tmpdir'

require 'launchy'
require 'myrurema/options'
require 'myrurema/version'

# Extend Pathname so that you can write 
#   foo / "bar"    #=> Pathname("foo/bar")
# instead of
#   foo + "bar"
class Pathname; alias / +; end

class MyRurema
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
           " --srcdir=#{bitclust_path}" +
           " --baseurl=http://localhost:#{port}" +
           " --port=#{port}" +
           " --database=#{db_path(@opt.rubyver)}" +
           " --debug" # needed to avoid the server running as daemon :-(
    }

    url = "http://localhost:#{port}/view/"
    puts "Starting BitClust server .."
    puts "Open #{url} in your browser."
    puts

    if @opt.open_browser
      sleep 1  # wait for the server to start
      Launchy.open(url)
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

  def puts(str="")
    Kernel.puts(str) unless $MYRUREMA_TEST
  end

end
