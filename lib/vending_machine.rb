# -*- coding: utf-8 -*-
class VendingMachine
  def initialize
    @amount = 0
  end

  def amount_of_drop_in
    @amount
  end

  def drop_in(money)
    @amount = money
  end
end

