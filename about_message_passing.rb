require File.expand_path(File.dirname(__FILE__) + '/neo')

class AboutMessagePassing < Neo::Koan

  class MessageCatcher
    def caught?
      true
    end
  end

  def test_methods_can_be_called_directly
    mc = MessageCatcher.new

    assert mc.caught?
  end

  def test_methods_can_be_invoked_by_sending_the_message
    mc = MessageCatcher.new

    assert mc.send(:caught?)
  end

  def test_methods_can_be_invoked_more_dynamically
    mc = MessageCatcher.new

    assert mc.send("caught?")
    assert mc.send("caught" + "?" )    # What do you need to add to the first string?
    assert mc.send("CAUGHT?".downcase )      # What would you need to do to the string?
  end

  def test_send_with_underscores_will_also_send_messages
    mc = MessageCatcher.new

    assert_equal true, mc.__send__(:caught?)

    # THINK ABOUT IT:
    #
    # Why does Ruby provide both send and __send__ ?
      # From StackOverflow(http://stackoverflow.com/questions/4658269/ruby-send-vs-send):

      # Short answer:

        # Some classes (for example the standard library's socket class) define their own send method which has nothing to do with Object#send. So if you want to work with objects of any class, you need to use __send__ to be on the safe side.

        # Now that leaves the question, why there is send and not just __send__. If there were only __send__ the name send could be used by other classes without any confusion. The reason for that is that send existed first and only later it was realized that the name send might also usefully be used in other contexts, so __send__ was added (that's the same thing that happened with id and object_id by the way).

      # Longer answer:
        # If you really need send to behave like it would normally do, you should use __send__, because it won't (it shouldn't) be overriden. Using __send__ is especially useful in metaprogramming, when you don't know what methods the class being manipulated defines. It could have overriden send.

        # Watch:

        # class Foo
        #   def bar?
        #     true
        #   end

        #   def send(*args)
        #     false
        #   end
        # end

        # foo = Foo.new
        # foo.send(:bar?)
        # # => false
        # foo.__send__(:bar?)
        # # => true

        # If you override __send__, Ruby will emit a warning:

        #     warning: redefining `__send__' may cause serious problems

        # Some cases where it would be useful to override send would be where that name is appropriate, like message passing, socket classes, etc.

  end

  def test_classes_can_be_asked_if_they_know_how_to_respond
    mc = MessageCatcher.new

    assert_equal true, mc.respond_to?(:caught?)
    assert_equal false, mc.respond_to?(:does_not_exist)
  end

  # ------------------------------------------------------------------

  class MessageCatcher
    # NOTE: This is a usage of the splat operator, which converts a set of parameters
    # into an array containing all parameters.
    #
    # This is NOT a pointer, like in C.

    def add_a_payload(*args)
      args
    end
  end

  def test_sending_a_message_with_arguments
    mc = MessageCatcher.new

    assert_equal [], mc.add_a_payload
    assert_equal [], mc.send(:add_a_payload)

    assert_equal [3, 4, nil, 6], mc.add_a_payload(3, 4, nil, 6)
    assert_equal [3, 4, nil, 6], mc.send(:add_a_payload, 3, 4, nil, 6)
  end

  # ------------------------------------------------------------------

  class TypicalObject
  end

  def test_sending_undefined_messages_to_a_typical_object_results_in_errors
    typical = TypicalObject.new

    exception = assert_raise(NoMethodError) do
      typical.foobar
    end
    assert_match(/foobar/, exception.message)
  end

  def test_calling_method_missing_causes_the_no_method_error
    typical = TypicalObject.new

    exception = assert_raise(NoMethodError) do
      typical.method_missing(:foobar)
    end
    assert_match(/foobar/, exception.message)

    # THINK ABOUT IT:
    #
    # If the method :method_missing causes the NoMethodError, then
    # what would happen if we redefine method_missing?
    #
    # NOTE:
    #
    # In Ruby 1.8 the method_missing method is public and can be
    # called as shown above. However, in Ruby 1.9 (and later versions)
    # the method_missing method is private. We explicitly made it
    # public in the testing framework so this example works in both
    # versions of Ruby. Just keep in mind you can't call
    # method_missing like that after Ruby 1.9 normally.
    #
    # Thanks.  We now return you to your regularly scheduled Ruby
    # Koans.

  end

  # ------------------------------------------------------------------

  class AllMessageCatcher
    def method_missing(method_name, *args, &block)
      "Someone called #{method_name} with <#{args.join(", ")}>"
    end
  end

  def test_all_messages_are_caught
    catcher = AllMessageCatcher.new

    assert_equal "Someone called foobar with <>", catcher.foobar
    assert_equal "Someone called foobaz with <1>", catcher.foobaz(1)
    assert_equal "Someone called sum with <1, 2, 3, 4, 5, 6>", catcher.sum(1,2,3,4,5,6)
  end

  def test_catching_messages_makes_respond_to_lie
    catcher = AllMessageCatcher.new

    # We define method_missing so no error will be raised.
    assert_nothing_raised do
      catcher.any_method
    end
    # Warning: We haven't defined any_method so it won't
    # respond but since we defined method_missing, if we called
    # the method directly then we'd get a result as if it existed.
    assert_equal false, catcher.respond_to?(:any_method)
  end

  # ------------------------------------------------------------------

  class WellBehavedFooCatcher
    def method_missing(method_name, *args, &block)
      if method_name.to_s[0,3] == "foo"
        "Foo to you too"
      else
        super(method_name, *args, &block)
      end
    end
  end

  def test_foo_method_are_caught
    catcher = WellBehavedFooCatcher.new

    assert_equal "Foo to you too", catcher.foo_bar
    assert_equal "Foo to you too", catcher.foo_baz
  end

  def test_non_foo_messages_are_treated_normally
    catcher = WellBehavedFooCatcher.new

    # Since the first three letters of the method name don't start
    # with "foo" the else statement executes and calls the parent
    # implementation which is the default implementation. The default
    # behavior of method_missing is to raise an error.
   assert_raise(NoMethodError) do
      catcher.normal_undefined_method
    end
  end

  # ------------------------------------------------------------------

  # (note: just reopening class from above)
  class WellBehavedFooCatcher
    def respond_to?(method_name)
      if method_name.to_s[0,3] == "foo"
        true
      else
        super(method_name)
      end
    end
  end

  def test_explicitly_implementing_respond_to_lets_objects_tell_the_truth
    catcher = WellBehavedFooCatcher.new

    # We can override the respond_to method and handle special cases.
    assert_equal true, catcher.respond_to?(:foo_bar)
    assert_equal false, catcher.respond_to?(:something_else)
  end

end
