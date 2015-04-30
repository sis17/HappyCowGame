require 'test_helper'

class GameTest < ActiveSupport::TestCase

  test "that an ingredient cateogry has many ingredients" do
    cat = ingredient_cats(:two_watercategory)
    assert_not_nil(cat.ingredients, "The ingredient cateogry has ingredients")
  end

  test "that an ingredient category has a game" do
    cat = ingredient_cats(:two_watercategory)
    assert_not_nil(cat.game, "The ingredient category has a game")
  end

  test "that the method to get ingredient category scores works for water" do
    cat = ingredient_cats(:two_watercategory)
    assert_nil(cat.get_score(''), "No absorbtion type gives nil as result.")
    assert_equal(1, cat.get_score('milk'), "Water gets 1 when absorbed as milk.")
    assert_equal(1, cat.get_score('meat'), "Water gets 1 when absorbed as meat.")
    assert_equal(1, cat.get_score('muck'), "Water gets 1 when absorbed as muck.")
  end

  test "that the method to get ingredient category scores works for energy" do
    cat = ingredient_cats(:two_energycategory)
    assert_nil(cat.get_score(''), "No absorbtion type gives nil as result.")
    assert_equal(6, cat.get_score('milk'), "Energy gets 6 when absorbed as milk.")
    assert_equal(2, cat.get_score('meat'), "Energy gets 2 when absorbed as meat.")
    assert_equal(1, cat.get_score('muck'), "Energy gets 1 when absorbed as muck.")
  end

  test "that the method to get ingredient category scores works for protien" do
    cat = ingredient_cats(:two_protiencategory)
    assert_nil(cat.get_score(''), "No absorbtion type gives nil as result.")
    assert_equal(3, cat.get_score('milk'), "Protein gets 3 when absorbed as milk.")
    assert_equal(4, cat.get_score('meat'), "Protein gets 4 when absorbed as meat.")
    assert_equal(1, cat.get_score('muck'), "Protein gets 1 when absorbed as muck.")
  end

  test "that the method to get ingredient category scores works for fiber" do
    cat = ingredient_cats(:two_fibercategory)
    assert_nil(cat.get_score(''), "No absorbtion type gives nil as result.")
    assert_equal(2, cat.get_score('milk'), "Fibre gets 2 when absorbed as milk.")
    assert_equal(2, cat.get_score('meat'), "Fibre gets 2 when absorbed as meat.")
    assert_equal(1, cat.get_score('muck'), "Fibre gets 1 when absorbed as muck.")
  end

  test "that the method to get ingredient category scores works for olgios" do
    cat = ingredient_cats(:two_oligoscategory)
    assert_nil(cat.get_score(''), "No absorbtion type gives nil as result.")
    assert_equal(10, cat.get_score('milk'), "Oligos gets 10 when absorbed as milk.")
    assert_equal(10, cat.get_score('meat'), "Oligos gets 10 when absorbed as meat.")
    assert_equal(1, cat.get_score('muck'), "Oligos gets 1 when absorbed as muck.")
  end

  test "that the oglios score decreases when oligos is absorbed" do
    cat = ingredient_cats(:two_oligoscategory)
    assert_equal(10, cat.get_score('milk'), "Oligos gets 10 when absorbed as milk.")
    assert_equal(10, cat.get_score('meat'), "Oligos gets 10 when absorbed as meat.")

    cow = cows(:twocow)
    cow.increase_oligos_marker(1)
    cat = IngredientCat.find(cat.id)
    assert_equal(2, cat.get_score('milk'), "Oligos now gets 2 when absorbed as milk.")
    assert_equal(2, cat.get_score('meat'), "Oligos now gets 2 when absorbed as meat.")

    cow.increase_oligos_marker(1)
    cat = IngredientCat.find(cat.id)
    assert_equal(0, cat.get_score('milk'), "Oligos now gets 0 when absorbed as milk.")
    assert_equal(0, cat.get_score('meat'), "Oligos now gets 0 when absorbed as meat.")
    assert_equal(1, cat.get_score('muck'), "Oligos still gets 1 when absorbed as muck.")
  end
end
