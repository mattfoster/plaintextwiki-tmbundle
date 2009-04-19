$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'test/unit'
require 'wiki'
require 'rubygems'
require 'mocha'

class PlainTextWikiTest < Test::Unit::TestCase
  def setup
    @dir = File.dirname(__FILE__) + '/wikidir'
    @subdir = "#{@dir}/testdir"
    @wiki = PlainTextWiki.new(@dir)
    @wiki.stubs(:refresh) # just so running the tests doesn't put focus on TextMate
  end
  
  def test_load_pages
    assert_equal ["indexpage", "testdir/testfile", "testdir/testfile2"], @wiki.send(:pages)
  end
  
  def test_whether_load_pages_sorts_by_downcased_names
    FileUtils.touch("#{@wiki.dir}/Zzz.txt")
    assert_equal ["indexpage", "testdir/testfile", "testdir/testfile2", "Zzz"], @wiki.send(:pages)
    FileUtils.rm("#{@wiki.dir}/Zzz.txt")
  end
  
  def test_is_absolute_link
    assert(@wiki.send(:is_absolute_link?, '/this'), "'/this' is an absolute path")
    assert(@wiki.send(:is_absolute_link?, '/this/stuff'), "'/this/stuff' is an absolute path")
    assert(@wiki.send(:is_absolute_link?, '/////this/stuff'), "'/////this/stuff' is an absolute path")
    assert(!@wiki.send(:is_absolute_link?, 'that'), "'that' is NOT an absolute path")
    assert(!@wiki.send(:is_absolute_link?, 'that/thing'), "'that/thing' is NOT an absolute path")
    assert(!@wiki.send(:is_absolute_link?, 'that/////thing'), "'that/////thing' is NOT an absolute path")
  end
  
  def test_go_to_link_uses_current_dir_when_link_is_not_absolute
    verify_go_to_link('relative', @subdir)
  end
  
  def test_go_to_link_uses_project_dir_when_link_is_absolute
    verify_go_to_link('/absolute', @dir)
  end
  
  def test_go_to_link_touches_file_when_it_doesnt_exist
    @wiki.expects(:touch_file).with(@dir, "nonexistent")
    @wiki.expects(:open_in_tm).with("#{@dir}/nonexistent.txt")
    @wiki.go_to("nonexistent")
  end
  
  def test_go_to_link_does_not_touch_file_when_it_exists
    @wiki.expects(:touch_file).never
    @wiki.expects(:open_in_tm).with("#{@dir}/indexpage.txt")
    @wiki.go_to("indexpage")
  end
  
  def test_go_to_link_does_not_touch_file_when_it_exists_with_different_case
    @wiki.expects(:touch_file).never
    @wiki.expects(:open_in_tm).with("#{@dir}/indexpage.txt")
    @wiki.go_to("InDExPagE")
  end
  
  def test_go_to_link_opens_correct_file_even_with_different_case
    @wiki.expects(:touch_file).never
    @wiki.expects(:open_in_tm).with("#{@dir}/indexpage.txt")
    @wiki.go_to("InDExPagE")
  end
  
  private
  def verify_go_to_link(pagename, root_dir)
    PlainTextWiki.const_set('ENV', {'TM_DIRECTORY' => @subdir, 'TM_PROJECT_DIRECTORY' => @dir})
    @wiki = PlainTextWiki.new(@subdir)
    @wiki.expects(:open_in_tm).with("#{root_dir}/#{pagename.gsub(/\//, '')}.txt")
    @wiki.expects(:refresh)
    @wiki.go_to(pagename)
    FileUtils.rm("#{root_dir}/#{pagename}.txt")
    PlainTextWiki.send(:remove_const, 'ENV')
  end
end