class MyRurema
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
          puts "myrurema version #{MyRurema::VERSION}"
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
end
