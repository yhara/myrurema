require File.expand_path("../src/myrurema", File.dirname(__FILE__))

$MYRUREMA_TEST = true

class MyRurema
  def sh(cmd, opt={})
    @cmds ||= []
    @cmds << cmd
  end
  attr_reader :cmds

  def exit; end
end

CASES = {
  "rurema --init" => [
    %r{svn co -rHEAD .*/doctree/trunk .*},
    %r{svn co -rHEAD .*/bitclust/trunk .*},
    %r{.*/bin/bitclust -d .* init version=.* encoding=euc-jp},
    %r{.*/bin/bitclust -d .* update --stdlibtree=.*/refm/api/src},
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

  "rurema --preview" => [
    %r{cd .*doctree/refm/api/src},
  ],

  "rurema --preview _builtin/Array" => [
    %r{bc-tohtml.*_builtin/Array .*rurema_preview.html},
  ],

  "rurema --preview _builtin/Array Array#pop" => [
    %r{bc-tohtml.*_builtin/Array --target=Array#pop.*rurema_preview.html},
  ],

  "rurema --preview Array --browser" => [
    %r{bc-tohtml},
    %r{(start|open) .*rurema_preview.html}
  ],
  "rurema --list" => [
    %r{refe.*-l},
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
