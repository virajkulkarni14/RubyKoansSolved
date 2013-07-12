require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutHashes < Neo::Koan
  def test_creating_hashes
    empty_hash = Hash.new
    assert_equal Hash, empty_hash.class
    assert_equal({}, empty_hash)
    assert_equal 0, empty_hash.size
  end

  def test_hash_literals
    hash = { :one => "uno", :two => "dos" }
    assert_equal 2, hash.size
  end

  def test_accessing_hashes
    hash = { :one => "uno", :two => "dos" }
    assert_equal "uno", hash[:one]
    assert_equal "dos", hash[:two]
    assert_equal nil, hash[:doesnt_exist]
  end

  def test_accessing_hashes_with_fetch
    hash = { :one => "uno" }
    assert_equal "uno", hash.fetch(:one)
    assert_raise(KeyError) do
      hash.fetch(:doesnt_exist)
    end

    # THINK ABOUT IT:
    #
    # Why might you want to use #fetch instead of #[] when accessing hash keys?
      # Answer:
      #   From StackOverflow:
      #     By default, using #[] will retrieve the hash value if it exists, and return nil if it doesn't exist *.
      #     Using #fetch gives you a few options:
      #       fetch(key_name): get the value if the key exists, raise a KeyError if it doesn't
      #       fetch(key_name, default_value): get the value if the key exists, return default_value otherwise
      #       fetch(key_name) { |key| "default" }: get the value if the key exists, otherwise run the supplied block and return the value.
      #     Each one should be used as the situation requires, but #fetch is very feature-rich and can many cases depending on how it's used.
  end

  def test_changing_hashes
    hash = { :one => "uno", :two => "dos" }
    hash[:one] = "eins"

    expected = { :one => "eins", :two => "dos" }
    assert_equal expected, hash

    # Bonus Question: Why was "expected" broken out into a variable
    # rather than used as a literal?
    # Answer:
    #   Because you can't write
    #     assert_equal { :one => "eins", :two => "dos" }, hash
    #   Ruby will interpret the above {...} as a block. Although
    #     assert_equal ({ :one => "eins", :two => "dos" }, hash)
    #   works fine.
  end

  def test_hash_is_unordered
    hash1 = { :one => "uno", :two => "dos" }
    hash2 = { :two => "dos", :one => "uno" }

    assert_equal true, hash1 == hash2
  end

  def test_hash_keys
    hash = { :one => "uno", :two => "dos" }
    assert_equal 2, hash.keys.size
    assert_equal true, hash.keys.include?(:one)
    assert_equal true, hash.keys.include?(:two)
    assert_equal Array, hash.keys.class
  end

  def test_hash_values
    hash = { :one => "uno", :two => "dos" }
    assert_equal 2, hash.values.size
    assert_equal true, hash.values.include?("uno")
    assert_equal true, hash.values.include?("dos")
    assert_equal Array, hash.values.class
  end

  # Note:
  #   Thus both, Hash Keys and Hash Values are returned as an Array.

  def test_combining_hashes
    hash = { "jim" => 53, "amy" => 20, "dan" => 23 }
    new_hash = hash.merge({ "jim" => 54, "jenny" => 26 })

    assert_equal true, hash != new_hash

    expected = { "jim" => 53, "amy" => 20, "dan" => 23, "jenny" => 26 }
    assert_equal false, expected == new_hash
  end

  # Note:
  #   Old key value was replaced with new value

  def test_default_value
    hash1 = Hash.new
    hash1[:one] = 1

    assert_equal 1, hash1[:one]
    assert_equal nil, hash1[:two]

    hash2 = Hash.new("dos")
    hash2[:one] = 1

    assert_equal 1, hash2[:one]
    assert_equal "dos", hash2[:two]
  end

  # Note:
  #   From RubyDoc:
  #     Hashes have a default value that is returned when accessing keys that do not exist in the hash. If no default is set nil is used. You can set the default value by sending it as an argument to ::new

  def test_default_value_is_the_same_object
    hash = Hash.new([])

    hash[:one] << "uno"
    hash[:two] << "dos"

    assert_equal ["uno", "dos"], hash[:one]
    assert_equal ["uno", "dos"], hash[:two]
    assert_equal ["uno", "dos"], hash[:three]

    assert_equal true, hash[:one].object_id == hash[:two].object_id
  end

  # Note:
  #   This one's seriously cool. Adding any element to the Array being used as default value is essentially modifying the same object!!


  def test_default_value_with_block
    hash = Hash.new {|hash, key| hash[key] = [] }

    hash[:one] << "uno"
    hash[:two] << "dos"

    assert_equal ["uno"], hash[:one]
    assert_equal ["dos"], hash[:two]
    assert_equal [], hash[:three]
  end

  # Note:
  #   This returns [] in the third case because that's what we defined as default in the block.
end
