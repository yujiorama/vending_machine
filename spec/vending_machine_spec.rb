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

describe MoneyStock do
  it "10円が5枚、のち6枚に更新" do
    money_stock = MoneyStock.new(Money::TEN, 5)
    money_stock.money.should == Money::TEN
    money_stock.stock.should == 5
    money_stock.stock = 6
    money_stock.stock.should == 6
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

describe DrinkStock do
  it "コーラ、在庫5本で6本に更新" do
    drink_stock = DrinkStock.new(Drink::COKE, 5)
    drink_stock.drink.should == Drink::COKE
    drink_stock.stock.should == 5
    drink_stock.stock = 6
    drink_stock.stock.should == 6
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
        vending_machine.drink_stock?(Drink::COKE).should be_false
      end
      it do
        vending_machine.drink_stock(Drink::COKE).should == 0
      end
    end

    describe "コーラの在庫がある場合" do
      it do
        vending_machine.refill_drink_stock(Drink::COKE, 1)
        vending_machine.drink_stock?(Drink::COKE).should be_true
      end

      it "コーラ1本" do
        vending_machine.refill_drink_stock(Drink::COKE, 1)
        vending_machine.drink_stock(Drink::COKE).should == 1
      end

      it "コーラ5本" do
        vending_machine.refill_drink_stock(Drink::COKE, 5)
        vending_machine.drink_stock(Drink::COKE).should == 5
      end
    end
  end

  describe "ジュースを購入する場合" do
    context "コーラが五本在庫としてある場合" do
      before do
        vending_machine.refill_drink_stock(Drink::COKE, 5)
      end

      it "120円で購入可能な商品を表示する" do
        vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
        vending_machine.purchaseable_drinks.should == [Drink::COKE]
      end

      it "お金を投入しないで購入可能な商品を表示する" do
        vending_machine.purchaseable_drinks.should == []
      end
    end

    context "コーラとレッドブルと水そそれぞれ五本在庫としてある場合" do
      before do
        vending_machine.refill_drink_stock(Drink::COKE, 5)
        vending_machine.refill_drink_stock(Drink::RED_BULL, 5)
        vending_machine.refill_drink_stock(Drink::WATER, 5)
      end

      it "100円で購入可能な商品を表示する" do
        vending_machine.drop_in(Money::HUNDRED)
        vending_machine.purchaseable_drinks.should == [Drink::WATER]
      end

      it "80円自動販売機にお釣りを用意しておき、200円で購入可能な商品を表示する" do
        vending_machine.refill_money_stock(Money::FIFTY, 1)
        vending_machine.refill_money_stock(Money::TEN, 3)
        vending_machine.drop_in(Money::HUNDRED, Money::HUNDRED)
        vending_machine.purchaseable_drinks.should == [Drink::COKE, Drink::RED_BULL, Drink::WATER]
      end

      it "自動販売機にお釣りを用意せず、200円で購入可能な商品を表示する" do
        vending_machine.drop_in(Money::HUNDRED, Money::HUNDRED)
        vending_machine.purchaseable_drinks.should == [Drink::RED_BULL, Drink::WATER]
      end


    end
   end

  it "120円でコーラを買う" do
    vending_machine.refill_drink_stock(Drink::COKE, 5)
    vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)

    vending_machine.purchase(Drink::COKE)

    vending_machine.earnings.should == 120
    vending_machine.drink_stock(Drink::COKE).should == 4
  end
  
  it "当たり判定オン、コーラ在庫2個で、120円でコーラを買う、当たりなので、2個排出され、在庫ゼロ" do
    vending_machine.bingo_on = true
    vending_machine.refill_drink_stock(Drink::COKE, 2)

    def vending_machine.rand100
      4
    end

    vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)

    vending_machine.purchase(Drink::COKE)

    vending_machine.earnings.should == 120
    vending_machine.drink_stock(Drink::COKE).should == 0
  end
  
  it "当たり判定オン、コーラとレッドブルそれぞれ在庫2個で、120円でコーラを買う、当たりなので、2個排出され、在庫ゼロ、続けて200円でレッドブルを買い、同じく当たりなので、2個排出、在庫ゼロ、コーラとレッドブルが当たり、合計320円" do
    vending_machine.bingo_on = true
    vending_machine.refill_drink_stock(Drink::COKE, 2)
    vending_machine.refill_drink_stock(Drink::RED_BULL, 2)

    def vending_machine.rand100
      4
    end

    vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
    vending_machine.purchase(Drink::COKE)

    vending_machine.drop_in(Money::HUNDRED, Money::HUNDRED)
    vending_machine.purchase(Drink::RED_BULL)
    
    vending_machine.bingo_drink_numbers[0].drink.should == Drink::COKE
    vending_machine.bingo_drink_numbers[0].number.should == 1
    vending_machine.bingo_drink_numbers[1].drink.should == Drink::RED_BULL
    vending_machine.bingo_drink_numbers[1].number.should == 1

    vending_machine.amount_of_bingos.should == 320
   end


  it "当たり判定オン、コーラ在庫2個で、120円でコーラを買う、はずれなので、1個排出され、在庫1" do
    vending_machine.bingo_on = true
    vending_machine.refill_drink_stock(Drink::COKE, 2)

    def vending_machine.rand100
      5  
    end

    vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)

    vending_machine.purchase(Drink::COKE)

    vending_machine.earnings.should == 120
    vending_machine.drink_stock(Drink::COKE).should == 1
  end

  it "30円自動販売機にお釣りが用意してあり、150円でコーラを買う" do
    vending_machine.refill_money_stock(Money::TEN, 3)
    vending_machine.refill_drink_stock(Drink::COKE, 5)

    vending_machine.drop_in(Money::HUNDRED, Money::FIFTY)
  
    vending_machine.purchase?(Drink::COKE).should be_true
    vending_machine.changes_if_purchase(Drink::COKE)[0].money.should == Money::TEN
    vending_machine.changes_if_purchase(Drink::COKE)[0].stock.should == 3

    vending_machine.purchase(Drink::COKE)

    vending_machine.earnings.should == 120
    vending_machine.drink_stock(Drink::COKE).should == 4
    vending_machine.amount_of_money_stocks.should == 150
  end
  
 it "150円でコーラを買おうとするがお釣りがないので買えない、無理矢理買おうとしても無理＞＜" do
    vending_machine.refill_drink_stock(Drink::COKE, 5)

    vending_machine.drop_in(Money::HUNDRED, Money::FIFTY)
  
    vending_machine.purchase?(Drink::COKE).should be_false

    proc {
      vending_machine.purchase(Drink::COKE)
    }.should raise_error(ArgumentError)
  end


  it "1000円5枚、硬貨は各10枚自動販売機にお釣りが用意してあり、150円でコーラを買う" do
    vending_machine.refill_money_stock(Money::TEN, 10)
    vending_machine.refill_money_stock(Money::FIFTY, 10)
    vending_machine.refill_money_stock(Money::HUNDRED, 10)
    vending_machine.refill_money_stock(Money::FIVE_HUNDRED, 10)
    vending_machine.refill_money_stock(Money::THOUSAND, 5)

    vending_machine.amount_of_money_stocks.should == 11600

    vending_machine.refill_drink_stock(Drink::COKE, 5)
    vending_machine.refill_drink_stock(Drink::RED_BULL, 5)
    vending_machine.refill_drink_stock(Drink::WATER, 5)

    vending_machine.drop_in(Money::HUNDRED, Money::FIFTY)
  
    vending_machine.purchase?(Drink::COKE).should be_true
    vending_machine.changes_if_purchase(Drink::COKE)[0].money.should == Money::TEN
    vending_machine.changes_if_purchase(Drink::COKE)[0].stock.should == 3

    vending_machine.purchase(Drink::COKE)

    vending_machine.earnings.should == 120
    vending_machine.drink_stock(Drink::COKE).should == 4
    vending_machine.amount_of_money_stocks.should == 11720
  end


  it "240円でコーラを2本買う" do
    vending_machine.refill_drink_stock(Drink::COKE, 5)
    vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
    vending_machine.purchase(Drink::COKE)
    vending_machine.drop_in(Money::HUNDRED, Money::TEN, Money::TEN)
    vending_machine.purchase(Drink::COKE)
    vending_machine.earnings.should == 240
    vending_machine.drink_stock(Drink::COKE).should == 3
  end



  describe "お釣りの計算をする" do
    context "お釣りが払える場合" do
      it "30円自動販売機にあって、10円投入して、40円のお釣りが払える場合" do
        vending_machine.refill_money_stock(Money::TEN, 3)
        vending_machine.drop_in(Money::TEN, Money::TEN)

        vending_machine.change?(40).should be_true
        vending_machine.changes(40)[0].money.should == Money::TEN
        vending_machine.changes(40)[0].stock.should == 4
      end

      it "50円自動販売機にあって、20円投入して、60円のお釣りが払える場合" do
        vending_machine.refill_money_stock(Money::FIFTY, 1)
        vending_machine.drop_in(Money::TEN, Money::TEN)

        vending_machine.changes(60)[0].money.should == Money::FIFTY
        vending_machine.changes(60)[0].stock.should == 1
        vending_machine.changes(60)[1].money.should == Money::TEN
        vending_machine.changes(60)[1].stock.should == 1
        vending_machine.new_money_stock_after_change(60)[0].money.should == Money::TEN
        vending_machine.new_money_stock_after_change(60)[0].stock.should == 1
        end
    end

    context "お釣りが払えない場合" do
      it "50円自動販売機にあって、30円のお釣りが払えない場合" do
        vending_machine.refill_money_stock(Money::FIFTY, 1)

        vending_machine.change?(30).should be_false
      end
    end
  end
  describe "当たり判定をする" do
    it "当たり判定オン、コーラの在庫が2個あり、当たり" do
      vending_machine.bingo_on = true
      vending_machine.refill_drink_stock(Drink::COKE, 2)
      
      def vending_machine.rand100
        4
      end
      
      vending_machine.bingo?(Drink::COKE).should be_true
    end

    it "当たり判定オフ(デフォルト)、コーラの在庫が2個あり、はずれ" do
      vending_machine.refill_drink_stock(Drink::COKE, 2)
      
      def vending_machine.rand100
        4
      end
      
      vending_machine.bingo?(Drink::COKE).should be_false
    end

    it "当たり判定オン、コーラの在庫が1個あり、はずれ" do
      vending_machine.bingo_on = true
      vending_machine.refill_drink_stock(Drink::COKE, 1)
      
      def vending_machine.rand100
        4
      end
      
      vending_machine.bingo?(Drink::COKE).should be_false
    end

    it "当たり判定オン、コーラの在庫が2個あり、5%に嵌まらなかった、はずれ" do
      vending_machine.bingo_on = true
      vending_machine.refill_drink_stock(Drink::COKE, 2)
      
      def vending_machine.rand100
        5
      end
      
      vending_machine.bingo?(Drink::COKE).should be_false
    end
  end
end
