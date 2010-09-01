require File.expand_path("../src/myrurema", File.dirname(__FILE__))

class MyRurema
  def sh(cmd, opt={})
    @cmds ||= []
    @cmds << cmd
  end
  attr_reader :cmds
end

CASES = {
  "rurema --init" => [
    %r{svn co .*doctree},
    %r{svn co .*bitclust},
    %r{bitclust.*init},
    %r{bitclust.*update},
  ],

  "rurema --init --rubyver=1.8.7" => [
    %r{bitclust.*init version=1.8.7}
  ],

  "rurema --init --ruremadir=/tmp" => [
    %r{svn co .*/tmp}
  ],

  "rurema --update" => [
    %r{svn up},
    %r{bitclust.*update}
  ],

  "rurema Array" => [
    %r{refe.*Array},
  ],

  "rurema --server" => [
    %r{standalone},
  ],

  "rurema --server --port=9898" => [
    %r{standalone.*--port=9898},
  ],

  "rurema --server --browser" => [
    %r{standalone},
    %r{(start|open) http://localhost:}
  ],
}

describe MyRurema do
  it "should execute expected commands" do
    CASES.each do |command, expects|
      opt = Options.new(command.split[1..-1])
      my = MyRurema.new(opt)
      my.run

      cmds = my.cmds
      i = 0
      expects.each do |pattern|
        pattern.should satisfy{
          i = cmds[i..-1].index{|cmd| pattern =~ cmd}
          not i.nil?
        }
        i += 1
      end
    end
  end
end
