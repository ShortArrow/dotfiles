describe("table basics", function()
  local table1 = {
    { name = "cat", age = 10 },
    { name = "dog", age = 2 },
    { name = "box" },
  }
  local table2 = {
    { name = "cake", age = 33 },
    { name = "box",  age = 1 },
    { name = "dog",  age = 5 },
  }

  local function merge_table() end

  before_each(function() end)

  it("merge", function()
    -- TODO: create table merge function
    assert.equals(table1[3].name, table2[2].name)
  end)

  it("for", function()
    local target = nil
    for _, v in pairs(table1) do
      target = v.name
    end
    assert.equals(table1[#table1].name, target)
  end)
end)
