require 'test_helper'

class ActsAsManyTenantsTest < ActiveSupport::TestCase
  test "truth" do
    assert_kind_of Module, ActsAsManyTenants
  end
end
