# -*- coding: utf-8 -*-
module Money
  class Money 
    attr :value

    def initialize(value)
      @value = value
    end
  end

  ONE = Money.new(1)
  FIVE = Money.new(5)
  TEN = Money.new(10)
  FIFTY = Money.new(50)
  HUNDRED = Money.new(100)
  FIVE_HUNDRED = Money.new(500)
  THOUSAND = Money.new(1000)
end

module Drink
  class Drink
    attr :id
    attr :name
    attr :value

    def initialize(id, name, value)
      @id = id
      @name = name
      @value = value
    end
  end

  COKE = Drink.new(1, "コーラ", 120)
  RED_BULL = Drink.new(2, "レッドブル", 200)
  WATER = Drink.new(3, "水", 100)
end

class VendingMachine
  def initialize
    @valid_money = [Money::TEN, Money::FIFTY, Money::HUNDRED, Money::FIVE_HUNDRED, Money::THOUSAND]
    @amount = 0
    @stock = {}
    @earnings = 0
  end

  def amount_of_drop_in
    @amount
  end

  def drop_in(*money)
    @amount += money.inject(0) do |sum, item|
      unless @valid_money.include?(item)
        raise ArgumentError, item.value
      end
      sum += item.value
    end
  end

  def refill(drink, number_of_pieces) 
    @stock[drink] = number_of_pieces
  end

  def stock?(drink)
    @stock.key?(drink) && @stock[drink] > 0
  end

  def stock(drink)
    @stock.key?(drink) ? @stock[drink] : 0
  end

  def purchaseable_drinks
    drinks = []
    @stock.keys.each do |drink|
      if stock?(drink)
        if drink.value <= amount_of_drop_in()
          drinks << drink.id
        end
      end
    end
    drinks 
  end

  def purchase(drink) 
    @stock[drink] = stock(drink) - 1
    @earnings += drink.value
    @amount = 0
  end

  def earnings
    @earnings
  end
end

