require File.expand_path("../lib/myrurema", File.dirname(__FILE__))

$MYRUREMA_TEST = true

# Override methods for testing
class MyRurema
  def sh(cmd, opt={})
    @cmds ||= []
    @cmds << cmd
  end
  attr_reader :cmds

  def exit; end
end

module Launchy; def self.open(*args); end; end

CASES = {
  "rurema --init" => [
    %r{svn co -rHEAD .*/doctree/trunk .*},
    %r{svn co -rHEAD .*/bitclust/trunk .*},
    %r{.*/bin/bitclust -d .* init version=.* encoding=utf-8},
    %r{.*/bin/bitclust -d .* update --stdlibtree=.*/refm/api/src},
  ],

  "rurema --init --rubyver=1.8.7" => [
    %r{.},
    %r{.},
    %r{bitclust.*init version=1.8.7},
    %r{.},
  ],

  "rurema --init --ruremadir=/tmp" => [
    %r{svn co .*/tmp},
    %r{.},
    %r{.},
    %r{.},
  ],

  "rurema --update" => [
    %r{svn up},
    %r{bitclust.*update}
  ],

  "rurema Array" => [
    %r{.*/refe Array -d .*}
  ],

  "rurema Ar i" => [
    %r{.*/refe Ar i -d .*},
  ],

  "rurema --server" => [
    %r{.*/standalone.rb --srcdir=.* --baseurl=http://localhost:.* --port=.* --database=.* --debug}
  ],

  "rurema --server --port=9898" => [
    %r{.*/standalone.rb --srcdir=.* --baseurl=http://localhost:.* --port=9898 --database=.* --debug}
  ],

  "rurema --server --browser" => [
    %r{.*/standalone.rb --srcdir=.* --baseurl=http://localhost:.* --port=.* --database=.* --debug}
    # Todo: Launchy.should_receive(:open)
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
  CASES.each do |command, expects|
    it "should respond to #{command}" do
      opt = MyRurema::Options.new(command.split.drop(1))
      my = MyRurema.new(opt)
      my.run

      # Get commands executed with `sh()`
      my.cmds.zip(expects).each do |cmd, pattern|
        cmd.should match(pattern)
      end
    end
  end
end
