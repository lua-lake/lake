describe('core.RuleSet', function()
  local RuleSet = require 'core.RuleSet'
  local rule_set

  before_each(function()
    rule_set = RuleSet()
  end)

  it('should start with rules empty', function()
    assert.are.same({}, rule_set.rules)
  end)

  it('should start with simple_dependencies empty', function()
    assert.are.same({}, rule_set.simple_dependencies)
  end)

  it('should allow adding a simple rule', function()
    local builder = load''

    rule_set.add_rule('target', 'dep', builder)

    assert.are.same({
      {
        target = 'target',
        deps = { 'dep' },
        builder = builder,
        subscribers = {},
        phony = false
      }
    }, rule_set.rules)
  end)

  it('should allow adding a phony rule', function()
    local builder = load''

    rule_set.add_phony('target', 'dep', builder)

    assert.are.same({
      {
        target = 'target',
        deps = { 'dep' },
        builder = builder,
        subscribers = {},
        phony = true
      }
    }, rule_set.rules)
  end)

  it('should allow adding a rule with multiple targets', function()
    local builder = load''

    rule_set.add_rule({ 'target1', 'target2' }, 'dep', builder)

    assert.are.same({
      {
        target = 'target2',
        deps = { 'dep' },
        builder = builder,
        subscribers = {},
        phony = false
      }, {
        target = 'target1',
        deps = { 'dep' },
        builder = builder,
        subscribers = {},
        phony = false
      }
    }, rule_set.rules)
  end)

  it('should allow adding a rule with multiple dependencies', function()
    local builder = load''

    rule_set.add_rule('target', { 'dep1', 'dep2' }, builder)

    assert.are.same({
      {
        target = 'target',
        deps = { 'dep1', 'dep2' },
        builder = builder,
        subscribers = {},
        phony = false
      }
    }, rule_set.rules)
  end)

  it('should allow adding a rule with no dependencies', function()
    local builder = load''

    rule_set.add_rule('target', {}, builder)

    assert.are.same({
      {
        target = 'target',
        deps = {},
        builder = builder,
        subscribers = {},
        phony = false
      }
    }, rule_set.rules)
  end)

  it('should provide an empty builder when a rule has no builder', function()
    rule_set.add_rule('target', {})

    assert.has_no_errors(function()
      rule_set.rules[1].builder()
    end)
  end)

  it('should use empty to indicate that no builder was provided to a rule', function()
    rule_set.add_rule('target1', {})

    assert.is_true(rule_set.rules[1].empty)
  end)

  it('should prioritize non-pattern rules', function()
    local builder1 = load''
    local builder2 = load''
    local patternBuilder = load''

    rule_set.add_rule('target1', {}, builder1)
    rule_set.add_rule('*.o', {}, patternBuilder)
    rule_set.add_rule('target2', {}, builder2)

    assert.are.same({
      {
        target = 'target2',
        deps = {},
        builder = builder2,
        subscribers = {},
        phony = false
      }, {
        target = 'target1',
        deps = {},
        builder = builder1,
        subscribers = {},
        phony = false
      }, {
        target = '*.o',
        deps = {},
        builder = patternBuilder,
        subscribers = {},
        phony = false
      }
    }, rule_set.rules)
  end)

  it('should allow adding a simple dependencies', function()
    rule_set.add_simple_dependency('target1', { 'dep1', 'dep2', 'dep3' })
    rule_set.add_simple_dependency('target2', { 'dep4', 'dep5' })

    assert.are.same({
      target1 = { 'dep1', 'dep2', 'dep3' },
      target2 = { 'dep4', 'dep5' }
    }, rule_set.simple_dependencies)
  end)

  it('should append to simple dependencies when the same target is used', function()
    rule_set.add_simple_dependency('target', { 'dep1', 'dep2', 'dep3' })
    rule_set.add_simple_dependency('target', { 'dep4', 'dep5' })

    assert.are.same({
      target = { 'dep1', 'dep2', 'dep3', 'dep4', 'dep5' }
    }, rule_set.simple_dependencies)
  end)
end)
