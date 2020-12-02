require 'test_helper'

class TagTest < ActiveSupport::TestCase
  test 'should reject empty name' do
    @tag = Tag.new description: 'without name'
    assert_not @tag.save, 'Saved a tag without a name'
  end

  test 'should accept empty description' do
    @tag = Tag.new name: 'name only'
    assert @tag.save, 'Rejected a valid tag'
  end

  test 'should reject duplicate names' do
    @tag = Tag.new name: 'duplicate'
    @tag.save!

    @tag = Tag.new name: 'duplicate',
                   description: 'two tags have the same name!'
    assert_not @tag.save, 'Saved two tags with the same name'
  end

  test 'should ignore case in duplication validation' do
    @tag = Tag.new name: 'CaseInsenSiTiVe'
    @tag.save!

    @tag = Tag.new name: 'caseinsensitive'
    assert_not @tag.save, 'Saved two tags with the same (case insensitive) name'
  end

  test 'should substitute whitespace' do
    @tag = Tag.new name: 'white    spac e'
    @tag.save!

    assert_equal @tag.name, 'white-spac-e'
  end

  test 'should ignore whitespace in duplication validation' do
    @tag = Tag.new name: 'whi  te    space'
    @tag.save!

    @tag = Tag.new name: 'whi te space'
    assert_not @tag.save, 'Saved two tags with the same (ignoring whitespace) name'

    @tag = Tag.new name: 'whi-te space'
    assert_not @tag.save, 'Saved two tags with the same (whitespace is hyphen) name'
  end

  test 'should accept valid tags' do
    @tag = Tag.new name: 'very valid'
    assert @tag.save, 'Rejected a valid tag'
  end
end
