require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutScope < Neo::Koan
  module Jims
    class Dog
      def identify
        :jims_dog
      end
    end
  end

  module Joes
    class Dog
      def identify
        :joes_dog
      end
    end
  end

  def test_dog_is_not_available_in_the_current_scope
    assert_raise(NameError) do
      Dog.new
    end
  end

  def test_you_can_reference_nested_classes_using_the_scope_operator
    fido = Jims::Dog.new
    rover = Joes::Dog.new
    assert_equal :jims_dog, fido.identify
    assert_equal :joes_dog, rover.identify

    assert_equal true, fido.class != rover.class
    assert_equal true, Jims::Dog != Joes::Dog
  # The identify method is used for the above comparison
  end

  # ------------------------------------------------------------------

  class String
  end

  def test_bare_bones_class_names_assume_the_current_scope
    assert_equal true, AboutScope::String == String
  end

  # Not a match because the String reference here matches the String
  # class within this class (AboutScope). That's the default behavior.
  # Whereas the string "HI" will use the language defined String class.
  def test_nested_string_is_not_the_same_as_the_system_string
    # puts String # > AboutScope::String
    # puts "HI".class # > String
    assert_equal false, String == "HI".class
  end

  def test_use_the_prefix_scope_operator_to_force_the_global_scope
    assert_equal true, ::String == "HI".class
  end

  # ------------------------------------------------------------------

  PI = 3.1416

  def test_constants_are_defined_with_an_initial_uppercase_letter
    assert_equal 3.1416, PI
  end

  # ------------------------------------------------------------------

  MyString = ::String

  # Class names are constants!
  def test_class_names_are_just_constants
    assert_equal true, MyString == ::String
    assert_equal true, MyString == "HI".class
  end

  # From ruby-doc:
  # const_get(sym, inherit=true) → obj
  #   Checks for a constant with the given name in mod If inherit is set, the lookup will also search the ancestors (and Object if mod is a Module.)
  #   The value of the constant is returned if a definition is found, otherwise a NameError is raised.
  def test_constants_can_be_looked_up_explicitly
    assert_equal true, PI == AboutScope.const_get("PI")
    assert_equal true, MyString == AboutScope.const_get("MyString")
  end

  def test_you_can_get_a_list_of_constants_for_any_class_or_module
    assert_equal [:Dog], Jims.constants
    assert Object.constants.size > 0
    # The below code will also work.
    # assert Object.constants.size > _n_(10)
  end
end
