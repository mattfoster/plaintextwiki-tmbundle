$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'wiki'
require 'p80'

class PlainTextWikiTest < Test::Unit::TestCase
  def setup
    @wiki = PlainTextWiki.new(File.dirname(__FILE__) + '/wikidir')
  end
  
  def test_load_pages
    assert_equal ["indexpage", "testdir/testfile", "testdir/testfile2"], @wiki.send(:pages)
  end
  
  def test_whether_load_pages_sorts_by_downcased_names
    FileUtils.touch("#{@wiki.dir}/Zzz.txt")
    assert_equal ["indexpage", "testdir/testfile", "testdir/testfile2", "Zzz"], @wiki.send(:pages)
    FileUtils.rm("#{@wiki.dir}/Zzz.txt")
  end
end