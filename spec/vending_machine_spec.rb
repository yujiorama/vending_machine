# -*- coding: utf-8 -*-
require 'rspec'

require 'vending_machine'

describe Money do
  it "許される通貨" do
    Money::TEN.value.should == 10
    Money::FIFTY.value.should == 50
    Money::HUNDRED.value.should == 100
    Money::FIVE_HUNDRED.value.should == 500
    Money::THOUSAND.value.should == 1000
  end
  it "許されない通貨" do
    Money::ONE.value.should == 1
    Money::FIVE.value.should == 5
  end
end

describe Drink do
  it "コーラ、レッドブル、水" do
    Drink::COKE.id.should == 1
    Drink::COKE.name.should == "コーラ"
    Drink::COKE.value.should == 120

    Drink::RED_BULL.id.should == 2
    Drink::RED_BULL.name.should == "レッドブル"
    Drink::RED_BULL.value.should == 200

    Drink::WATER.id.should == 3 
    Drink::WATER.name.should == "水"
    Drink::WATER.value.should == 100
  end
end

describe VendingMachine do
  let(:vending_machine) {VendingMachine.new}

  it "初期状態では合計金額が０円" do
     vending_machine.amount_of_drop_in.should == 0
  end

  describe "お金を1つだけ投入する場合" do
    it "10円" do
      money = Money::TEN
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == 10
    end
    it "50円" do
      money = Money::FIFTY
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == 50
    end
    it "100円" do
      money = Money::HUNDRED
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == 100
    end
    it "500円" do
      money = Money::FIVE_HUNDRED
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == 500
    end
    it "1000円" do
      money = Money::THOUSAND
      vending_machine.drop_in(money)
      vending_machine.amount_of_drop_in.should == 1000
    end
  end

  describe "許可しないお金を入れた場合" do
    it "1円" do
      proc { vending_machine.drop_in(Money::One)
      }.should raise_error
    end
    it "5円" do
      proc { vending_machine.drop_in(Money::FIVE)
      }.should raise_error
    end
  end

  describe "2つ以上の有効なお金を入れた場合" do
    describe "有効なお金だけの場合" do
      it "10円,50円,10円" do
        vending_machine.drop_in(Money::TEN, Money::FIFTY, Money::TEN)
        vending_machine.amount_of_drop_in.should == 70
      end
      it "10円,50円,100円" do
        vending_machine.drop_in(Money::TEN, Money::FIFTY, Money::HUNDRED)
        vending_machine.amount_of_drop_in.should == 160
      end
    end

     describe "有効なお金を連続投入した場合" do
      it "10円,50円,10円" do
        vending_machine.drop_in(Money::TEN, Money::FIFTY, Money::TEN)
        vending_machine.drop_in(Money::FIFTY)
        vending_machine.amount_of_drop_in.should == 120
      end
    end
    
    describe "1つ以上の無効なお金が含まれる場合" do
      it "10円,1円,100円" do
        proc {
          vending_machine.drop_in(Money::TEN, Money::ONE, Money::HUNDRED)
        }.should raise_error(ArgumentError, "1")
        vending_machine.amount_of_drop_in.should == 0
      end
      it "1円,100円" do
        proc {
          vending_machine.drop_in(Money::ONE, Money::HUNDRED)
        }.should raise_error(ArgumentError, "1")
        vending_machine.amount_of_drop_in.should == 0
      end
    end
  end

  describe "在庫状況を確認する" do
    describe "コーラの在庫がない場合" do
      it do
        vending_machine.stock?(Drink::COKE).should be_false
      end
      it do
        vending_machine.stock(Drink::COKE).should == 0
      end
    end

    describe "コーラの在庫がある場合" do
      it do
        vending_machine.refill(Drink::COKE, 1)
        vending_machine.stock?(Drink::COKE).should be_true
      end

      it "在庫数" do
        vending_machine.refill(Drink::COKE, 1)
        vending_machine.stock(Drink::COKE).should == 1
      end

      it "コーラ5本" do
        vending_machine.refill(Drink::COKE, 5)
        vending_machine.stock(Drink::COKE).should == 5
      end
    end
  end

  describe "ジュースを購入する場合" do
    it "120円で購入可能な商品IDを表示する" do
      vending_machine.refill(Drink::COKE, 5)
      vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
      vending_machine.purchaseable_drinks.should == [1]
    end
    it "お金を投入しないで購入可能な商品IDを表示する" do
      vending_machine.refill(Drink::COKE, 5)
      vending_machine.purchaseable_drinks.should == []
    end
  end

    it "120円でコーラを買う" do
      vending_machine.refill(Drink::COKE, 5)
      vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
      vending_machine.purchase(Drink::COKE)
      vending_machine.earnings.should == 120
      vending_machine.stock(Drink::COKE).should == 4
    end
    
    it "240円でコーラを2本買う" do
      vending_machine.refill(Drink::COKE, 5)
      vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
      vending_machine.purchase(Drink::COKE)
      vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
      vending_machine.purchase(Drink::COKE)
      vending_machine.earnings.should == 240
      vending_machine.stock(Drink::COKE).should == 3
    end
 
end
