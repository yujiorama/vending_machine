# -*- coding: utf-8 -*-
class VendingMachine
  def initialize
    @amount = 0
  end

  def amount_of_drop_in
    @amount
  end

  def drop_in(*money)
    @amount = money.inject(0) do |sum, item|
      if item == 1 || item == 5
        raise "invalid money"
      end
      sum += item
    end
  end
end

