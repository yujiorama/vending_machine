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

class VendingMachine
  def initialize
    @valid_money = [Money::TEN, Money::FIFTY, Money::HUNDRED, Money::FIVE_HUNDRED, Money::THOUSAND]
    @amount = 0
    @stock = {}
    @price = { 1 => 120, 2 => 200, 3 => 150 }
    @earnings = 0
  end

  def amount_of_drop_in
    @amount
  end

  def drop_in(*money)
    @amount = money.inject(0) do |sum, item|
      unless @valid_money.include?(item)
        raise "invalid money"
      end
      sum += item.value
    end
  end

  def refill(id, number_of_pieces) 
    @stock[id] = number_of_pieces
  end

  def stock?(id)
    @stock.key?(id) && @stock[id] > 0
  end

  def stock(id)
    @stock.key?(id) ? @stock[id] : 0
  end

  def purchaseable_drinks
    drinks = []
    @stock.keys.each do |key|
      if stock?(key)
        if @price[key] <= amount_of_drop_in()
          drinks << key
        end
      end
    end
    drinks 
  end

  def purchase(id) 
    @stock[id] = stock(id) - 1
    @earnings += @price[id]
  end

  def earnings
    @earnings
  end
end

