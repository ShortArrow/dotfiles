describe('api test', function()

  local utils = require('my').utils

  before_each(function()
  end)
    local sample = function()
    end
    assert.equals(true, utils.is_function(sample))
  end)

  it('not function is false', function()
    local sample = nil
    assert.equals(false, utils.is_function(sample))
  end)

  it('boolean is true', function()
    local sample = true
    assert.equals(true, utils.is_boolean(sample))
  end)

  it('returned boolean is true', function()
    local sample = function() return false end
    assert.equals(true, utils.is_boolean(sample()))
  end)

  it('not boolean is false', function()
    local sample = nil
    assert.equals(false, utils.is_boolean(sample))
  end)

end)
