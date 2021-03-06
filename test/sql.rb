require_relative 'test_helper'
# require 'parslet'

class ParserTest < MiniTest::Unit::TestCase
  #include Eql

  def setup
    @parser = Eql::Sql::Parser.new
  end

  def teardown
  end

  def test_simples # check syntax parser with parslet
    [
     'select a from b',
     'select a, b from comme',
     'select b from far',
     'select c from d',
     'select a, c, d,e,f,f from b ',
     'select count(a) from d',
    ].each do |sql|
      s = @parser.parse sql
      assert_equal(expected = "select", actual = s[:op])
      assert(! s[:select].nil?)
      assert(! s[:from].nil?)
      assert(! (Eql.build s).nil?)
    end
  end

  def test_bad_sql
    [
     'select',
     ' select a from b',
     'select a, b from c where a = "120.0, ~!@#$%^&*+_\}{\" asdfa"sf"',
     ].each do |bad_sql|
      assert_raises Parslet::ParseFailed do
        @parser.parse bad_sql
      end
    end
  end

  def test_where
    [
     'select a from b where a > 20',
     'select a,b from c where a = 20',
     'select a,b from c where 20 < a and b < 234',
     'select a,b from c where 20 < a or b = 234',
     'select a, b from c where a = "oo"',
     'select a, b from c where a = "oo" and c > 235',
     'select a, b from c where a = "120.0, ~!@#$%^&*+_\}{\" asdfasf"',
     #'select a from b where a > 20.0',
     #'select a from b where a > 0.0',
     #'select a from b where a > -0',
    ].each do |where_sql|
      s = @parser.parse where_sql
      assert_equal(expected = "select", actual = s[:op])
      assert(! s[:select].nil?)
      assert(! s[:from].nil?)
      assert(! s[:where].nil?)
      assert(! (Eql.build s).nil?)
    end
  end

  def test_group_by
    [
     'select a from b group by c',
     'select a from b where a > 345 group by c',
     'select a from b where a > 345 and foo = "hoge" group by c',
    ].each do |where_sql|
      s = @parser.parse where_sql
      assert_equal(expected = "select", actual = s[:op])
      assert(! s[:select].nil?)
      assert(! s[:from].nil?)
      assert(! s[:group_by].nil?)
      assert(! (Eql.build s).nil?)
    end
  end
  def test_join
    [ 
      'select a from b where x=1 and y = "2" and z = true join c,d on e = f group by c',
      'select a from b join c,d on e = f and x = 2 and y = "abc" and z = true group by c'
    # 'select a from b join c on e = f group by c',
    # 'select a from b where a > 345 group by c',
     # 'select a from b where a > 345 and foo = "hoge" group by c',
    ].each do |where_sql|
    begin
      s = @parser.parse where_sql
      puts s
    rescue Parslet::ParseFailed => failure
        fail failure.cause.ascii_tree
    end
      assert_equal(expected = "select", actual = s[:op])
      assert(! s[:select].nil?)
      assert(! s[:from].nil?)
      assert(! s[:join].nil?)
      assert(! s[:group_by].nil?)
      assert(! (Eql.build s).nil?)
    end
  end

  def test_ref
    [ 
      'select a from b',
      'select a from b where a.x = 2 and y = "abc" and z = true group by c'
    # 'select a from b join c on e = f group by c',
    # 'select a from b where a > 345 group by c',
     # 'select a from b where a > 345 and foo = "hoge" group by c',
    ].each do |where_sql|
    begin
      s = @parser.parse where_sql
      puts s
    rescue Parslet::ParseFailed => failure
        fail failure.cause.ascii_tree
    end
      assert_equal(expected = "select", actual = s[:op])
      assert(! s[:select].nil?)
      assert(! s[:from].nil?)
      assert(! (Eql.build s).nil?)
    end
  end
  def test_alias
    [ 
      'select a as a2 from b',
      'select a as a2,c as c2 from b as b2',
      'select a as a2 from b as b2,c as c2',
      'select a.x as x from b as b2,c as c2'
      #,
      #'select a from b where a.x = 2 and y = "abc" and z = true group by c'
    # 'select a from b join c on e = f group by c',
    # 'select a from b where a > 345 group by c',
     # 'select a from b where a > 345 and foo = "hoge" group by c',
    ].each do |where_sql|
    begin
      s = @parser.parse where_sql
      puts s
    rescue Parslet::ParseFailed => failure
        fail failure.cause.ascii_tree
    end
      assert_equal(expected = "select", actual = s[:op])
      assert(! s[:select].nil?)
      assert(! s[:from].nil?)
      assert(! (Eql.build s).nil?)
    end
  end
end
