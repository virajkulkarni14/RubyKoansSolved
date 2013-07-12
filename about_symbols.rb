require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutSymbols < Neo::Koan
  def test_symbols_are_symbols
    symbol = :ruby
    assert_equal true, symbol.is_a?(Symbol)
  end

  def test_symbols_can_be_compared
    symbol1 = :a_symbol
    symbol2 = :a_symbol
    symbol3 = :something_else

    assert_equal true, symbol1 == symbol2
    assert_equal false, symbol1 == symbol3
  end

  def test_identical_symbols_are_a_single_internal_object
    symbol1 = :a_symbol
    symbol2 = :a_symbol

    assert_equal true, symbol1           == symbol2
    assert_equal true, symbol1.object_id == symbol2.object_id
  end

  def test_method_names_become_symbols
    symbols_as_strings = Symbol.all_symbols.map { |x| x.to_s }
    assert_equal true, symbols_as_strings.include?("test_method_names_become_symbols")
  end

  # THINK ABOUT IT:
  #
  # Why do we convert the list of symbols to strings and then compare
  # against the string value rather than against symbols?
  # Answer:
  #   This one is tough to understand. From StackOverflow:
  #     This has to do with how symbols work. For each symbol, only one of it actually exists. Behind the scenes, a symbol is just a number referred to by a name (starting with a colon). Thus, when comparing the equality of two symbols, you're comparing object identity and not the content of the identifier that refers to this symbol.
  #     If you were to do the simple test :test == "test", it will be false. So, if you were to gather all of the symbols defined thus far into an array, you would need to convert them to strings first before comparing them. You can't do this the opposite way (convert the string you want to compare into a symbol first) because doing that would create the single instance of that symbol and "pollute" your list with the symbol you're testing for existence.

  in_ruby_version("mri") do
    RubyConstant = "What is the sound of one hand clapping?"
    def test_constants_become_symbols
      all_symbols_as_strings = Symbol.all_symbols.map { |x| x.to_s }

      assert_equal false, all_symbols_as_strings.include?(RubyConstant)
    end
  end

  def test_symbols_can_be_made_from_strings
    string = "catsAndDogs"
    assert_equal :catsAndDogs, string.to_sym
  end

  def test_symbols_with_spaces_can_be_built
    symbol = :"cats and dogs"

    assert_equal :"cats and dogs".to_sym, symbol
  end

  def test_symbols_with_interpolation_can_be_built
    value = "and"
    symbol = :"cats #{value} dogs"

    assert_equal :"cats and dogs".to_sym, symbol
  end

  def test_to_s_is_called_on_interpolated_symbols
    symbol = :cats
    string = "It is raining #{symbol} and dogs."

    assert_equal "It is raining cats and dogs.", string
  end

  def test_symbols_are_not_strings
    symbol = :ruby
    assert_equal false, symbol.is_a?(String)
    assert_equal false, symbol.eql?("ruby")
  end

  def test_symbols_do_not_have_string_methods
    symbol = :not_a_string
    assert_equal false, symbol.respond_to?(:each_char)
    assert_equal false, symbol.respond_to?(:reverse)
  end

  # It's important to realize that symbols are not "immutable
  # strings", though they are immutable. None of the
  # interesting string operations are available on symbols.

  def test_symbols_cannot_be_concatenated
    # Exceptions will be pondered further down the path
    assert_raise(NoMethodError) do
      :cats + :dogs
    end
  end

  def test_symbols_can_be_dynamically_created
    assert_equal :catsdogs, ("cats" + "dogs").to_sym
  end

  # THINK ABOUT IT:
  #
  # Why is it not a good idea to dynamically create a lot of symbols?
  # Answer:
  #   Because symbols are immutable, they persist in memory till program exits. Dynamically creating and not reusing symbols results in memory wastage.
end
