#!/usr/bin/env ruby -w

require 'minitest/autorun'
require 'open3'

class TestEx00 < Minitest::Test
  def test_var_output
    output, status = Open3.capture2("ruby /app/ex00/var.rb")
    assert_equal 0, status.exitstatus

    assert_match(/my variables/, output)
    assert_match(/a contains: 10 and is a type: (Integer|Fixnum)/, output)
    assert_match(/b contains: 10 and is a type: String/, output)
    assert_match(/c contains: nil and is a type: NilClass/, output)
    assert_match(/d contains: 10\.0 and is a type: Float/, output)
  end
end

class TestEx01 < Minitest::Test
  def test_croissant_sorts_numbers
    output, status = Open3.capture2("ruby /app/ex01/croissant.rb")
    assert_equal 0, status.exitstatus

    numbers = output.strip.split("\n").map(&:to_i)
    assert_equal numbers.sort, numbers
    assert numbers.first < numbers.last
  end
end

class TestEx02 < Minitest::Test
  def test_h2o_output
    output, status = Open3.capture2("ruby /app/ex02/H2o.rb")
    assert_equal 0, status.exitstatus

    assert_match(/24 : Caleb/, output)
    assert_match(/84 : Calixte/, output)
    assert_match(/1 : Carl/, output)
  end
end

class TestEx03 < Minitest::Test
  def test_where_oregon
    output, status = Open3.capture2("ruby /app/ex03/Where.rb Oregon")
    assert_equal 0, status.exitstatus
    assert_equal "Salem\n", output
  end

  def test_where_alabama
    output, status = Open3.capture2("ruby /app/ex03/Where.rb Alabama")
    assert_equal 0, status.exitstatus
    assert_equal "Montgomery\n", output
  end

  def test_where_unknown
    output, status = Open3.capture2("ruby /app/ex03/Where.rb toto")
    assert_equal 0, status.exitstatus
    assert_equal "Unknown state\n", output
  end

  def test_where_no_args
    output, status = Open3.capture2("ruby /app/ex03/Where.rb")
    assert_equal 0, status.exitstatus
    assert_equal "", output
  end

  def test_where_too_many_args
    output, status = Open3.capture2("ruby /app/ex03/Where.rb Oregon Alabama")
    assert_equal 0, status.exitstatus
    assert_equal "", output
  end
end

class TestEx04 < Minitest::Test
  def test_erehw_salem
    output, status = Open3.capture2("ruby /app/ex04/erehW.rb Salem")
    assert_equal 0, status.exitstatus
    assert_equal "Oregon\n", output
  end

  def test_erehw_montgomery
    output, status = Open3.capture2("ruby /app/ex04/erehW.rb Montgomery")
    assert_equal 0, status.exitstatus
    assert_equal "Alabama\n", output
  end

  def test_erehw_unknown
    output, status = Open3.capture2("ruby /app/ex04/erehW.rb toto")
    assert_equal 0, status.exitstatus
    assert_equal "Unknown capital city\n", output
  end

  def test_erehw_no_args
    output, status = Open3.capture2("ruby /app/ex04/erehW.rb")
    assert_equal 0, status.exitstatus
    assert_equal "", output
  end
end

class TestEx05 < Minitest::Test
  def test_whereto_mixed
    output, status = Open3.capture2('ruby /app/ex05/whereto.rb "Salem, Alabama, Toto, MontGOmery"')
    assert_equal 0, status.exitstatus

    lines = output.strip.split("\n")
    assert_equal 4, lines.length
    assert_match(/Salem is the capital of Oregon \(akr: OR\)/, lines[0])
    assert_match(/Montgomery is the capital of Alabama \(akr: AL\)/, lines[1])
    assert_match(/Toto is neither a capital city nor a state/, lines[2])
    assert_match(/Montgomery is the capital of Alabama \(akr: AL\)/, lines[3])
  end

  def test_whereto_case_insensitive
    output, status = Open3.capture2('ruby /app/ex05/whereto.rb "OREGON"')
    assert_equal 0, status.exitstatus
    assert_match(/Salem is the capital of Oregon/, output)
  end

  def test_whereto_double_comma_no_output
    output, status = Open3.capture2('ruby /app/ex05/whereto.rb "Salem,,Alabama"')
    assert_equal 0, status.exitstatus
    assert_equal "", output
  end

  def test_whereto_no_args
    output, status = Open3.capture2("ruby /app/ex05/whereto.rb")
    assert_equal 0, status.exitstatus
    assert_equal "", output
  end

  def test_whereto_too_many_args
    output, status = Open3.capture2('ruby /app/ex05/whereto.rb "Salem" "Oregon"')
    assert_equal 0, status.exitstatus
    assert_equal "", output
  end
end

class TestEx06 < Minitest::Test
  def test_coffee_croissant_order
    output, status = Open3.capture2("ruby /app/ex06/CoffeeCroissant.rb")
    assert_equal 0, status.exitstatus

    names = output.strip.split("\n")
    assert_equal ["Stacy", "Jill", "Juan", "Steve", "Dom", "Frank"], names
  end
end

class TestEx07 < Minitest::Test
  def test_elm_generates_html
    output, status = Open3.capture2("ruby /app/ex07/elm.rb")
    assert_equal 0, status.exitstatus

    html_file = "/app/ex07/periodic_table.html"
    assert File.exist?(html_file), "periodic_table.html should be created"

    html_content = File.read(html_file)
    assert_match(/<html/, html_content)
    assert_match(/<table>/, html_content)
    assert_match(/<h4>Hydrogen<\/h4>/, html_content)
    assert_match(/<li>No 1<\/li>/, html_content)
    assert_match(/<li>H<\/li>/, html_content)
    assert_match(/<li>1\.00794<\/li>/, html_content)
    assert_match(/<li>1 electron<\/li>/, html_content)
    assert_match(/<\/table>/, html_content)
    assert_match(/<\/html>/, html_content)
  end
end
