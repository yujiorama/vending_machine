# -*- coding: utf-8 -*-
require 'rspec'

require 'vending_machine'

describe VendingMachine do
  let(:vending_machine) {VendingMachine.new}

  it "初期状態では合計金額が０円" do
     vending_machine.amount_of_drop_in.should == 0
  end

  describe "お金を1つだけ投入する場合" do
    it "10円" do
      vending_machine.drop_in(10)
      vending_machine.amount_of_drop_in.should == 10
    end
  end
end
