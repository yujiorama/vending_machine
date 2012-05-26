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
      money = 10
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == money
    end
    it "50円" do
      money = 50
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == money
    end
    it "100円" do
      money = 100
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == money
    end
    it "500円" do
      money = 500
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == money
    end
    it "1000円" do
      money = 1000
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == money
    end
  end

  describe "許可しないお金を入れた場合" do
    it "1円" do
      proc { vending_machine.drop_in(1)
      }.should raise_error
    end
    it "5円" do
      proc { vending_machine.drop_in(5)
      }.should raise_error
    end
  end

  describe "2つ以上の有効なお金を入れた場合" do
    describe "有効なお金だけの場合" do
      it "10円,50円,10円" do
        vending_machine.drop_in(10, 50, 10)
        vending_machine.amount_of_drop_in.should == 70
      end
      it "10円,50円,100円" do
        vending_machine.drop_in(10, 50, 100)
        vending_machine.amount_of_drop_in.should == 160
      end
    end
    describe "1つ以上の無効なお金が含まれる場合" do
      it "10円,1円,100円" do
        proc {
          vending_machine.drop_in(10,1,100)
        }.should raise_error
      end
      it "1円,100円" do
        proc {
          vending_machine.drop_in(1,100)
        }.should raise_error
      end
    end
   end

  describe "在庫を有無を確認する" do
    it "在庫がない場合" do
      vending_machine.stock?({:id => 1})
    end
  end
end
