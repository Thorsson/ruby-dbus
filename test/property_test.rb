#!/usr/bin/env ruby
require "test/unit"
require "dbus"

class PropertyTest < Test::Unit::TestCase
  def setup
    session_bus = DBus::SessionBus.instance
    svc = session_bus.service("org.ruby.service")
    @obj = svc.object("/org/ruby/MyInstance")
    @obj.introspect
    @iface = @obj["org.ruby.SampleInterface"]
  end

  def test_property_reading
    assert_equal "READ ME", @iface["ReadMe"]
  end

  def test_property_nonreading
    e = assert_raises DBus::Error do
      @iface["WriteMe"]
    end
    assert_match(/not readable/, e.to_s)
  end

  def test_property_writing
    @iface["ReadOrWriteMe"] = "VALUE"
    assert_equal "VALUE", @iface["ReadOrWriteMe"]
  end

  def test_property_nonwriting
    e = assert_raises DBus::Error do
      @iface["ReadMe"] = "WROTE"
    end
    assert_match(/not writable/, e.to_s)
  end

  def test_get_all
    all = @iface.all_properties
    assert_equal ["ReadMe", "ReadOrWriteMe"], all.keys.sort
  end

  def test_unknown_property_reading
    e = assert_raises DBus::Error do
      @iface["Spoon"]
    end
    assert_match(/not found/, e.to_s)
  end

  def test_unknown_property_writing
    e = assert_raises DBus::Error do
      @iface["Spoon"] = "FORK"
    end
    assert_match(/not found/, e.to_s)
  end
end
