require 'spec_helper'

describe SubsidyCalculations::Calculation do
  let(:calculation) {SubsidyCalculations::Calculation.new}

  describe "build_for_family" do
    before do
      Timecop.freeze(Date.new(2010,1,1))
    end
    context "empty family" do
      before do
        @family = Querying::Family.new
      end
      it "should build calculation object with proper family fields calculated" do
        calc = SubsidyCalculations::Calculation.build_from_family(@family, Date.today)
        calc.household_size.should == 0
        calc.household_income.should == ""
        calc.adult_age.should == nil
        calc.spouse_age.should == nil
        calc.younger_children.should == nil
        calc.older_children.should == nil
        calc.eligible_for_employer_plan.should == false
      end
      context "with applicant" do
        before do
          @family.applicant = Querying::Applicant.new(:date_of_birth => '1980-01-01')
          @family.members << @family.applicant
        end
        it "should build calculation object with proper size/applicant-age" do
          calc = SubsidyCalculations::Calculation.build_from_family(@family, Date.today)
          calc.household_size.should == 1
          calc.adult_age.should == 30
        end
        context "with income specified" do
          before do
            @family.household_income = 20000
          end
          it "should fill in income on the calculation object" do
            calc = SubsidyCalculations::Calculation.build_from_family(@family, Date.today)
            calc.household_income.should == "20000"
          end
        end
        context "when effective_date is different from today" do
          before do
            @effective_date = Date.new(2009,12,31)
          end
          it "should calculate ages based on effective-date" do
            calc = SubsidyCalculations::Calculation.build_from_family(@family, @effective_date)
            calc.adult_age.should == 29
          end
        end
        context "and spouse" do
          before do
            @family.spouse = Querying::Spouse.new(:date_of_birth => '1982-01-01')
            @family.members << @family.spouse
          end
          it "should build calculation object with proper size/spouse-age" do
            calc = SubsidyCalculations::Calculation.build_from_family(@family, Date.today)
            calc.household_size.should == 2
            calc.spouse_age.should == 28
          end
          context "and 3 children" do
            before do
              @family.children = [
                Querying::Child.new(:date_of_birth => '1989-01-01'),
                Querying::Child.new(:date_of_birth => '1988-01-01'),
                Querying::Child.new(:date_of_birth => '2005-01-01')
              ]
              @family.children.each { |c| @family.members << c }
            end
            it "x" do
              calc = SubsidyCalculations::Calculation.build_from_family(@family, Date.today)
              calc.household_size.should == 5
              calc.younger_children.should == 1
              calc.older_children.should == 2
            end
          end
        end

      end

    end
  end

  describe ".new_or_invalid?" do
    it "returns true if new_flag is true and calculation is invalid" do
      calculation.new_flag = true
      calculation.stub(:valid?) { false }
      expect(calculation.new_or_invalid?).to be_true
    end
    it "returns true if new_flag is false but calculation is invalid" do
      calculation.new_flag = false
      calculation.stub(:valid?) { false }
      expect(calculation.new_or_invalid?).to be_true
    end
    it "returns false if new_flag is false and calculation is valid" do
      calculation.new_flag = false
      calculation.stub(:valid?) { true }
      expect(calculation.new_or_invalid?).to be_false
    end
  end

  context "calculates FPLP" do
    it "for single adult" do
      expect(calculation.calculate_fpl_percentage(1, 11_490)).to eq(100)
    end

    it "for single adult with higher income" do
      expect(calculation.calculate_fpl_percentage(1, 11_490*2)).to eq(200)
    end
  end

  it "handles string inputs properly" do
    expect(calculation.calculate_fpl_percentage(1.to_s, 11_490.to_s)).to eq(100)
  end

  context "validations for" do
    let(:valid_calculation) {SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => 33, :spouse_age => "")}

    it "a valid calculation" do
      valid_calculation.should be_valid
    end

    context "household_income" do
      it "must be a number" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "a", :household_size => 2, :adult_age => 33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:household_income)
      end

      it "cannot be negative" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "-20,000", :household_size => 2, :adult_age => 33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:household_income)
      end

      it "cannot be blank" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "", :household_size => 2, :adult_age => 33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:household_income)
      end
    end

    context "household_size" do
      it "cannot be blank" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "10,000", :household_size => "", :adult_age => 33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:household_size)
      end

      it "must be a number" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "10,000", :household_size => "a", :adult_age => 33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:household_size)
      end

      it "cannot be negative" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "10,000", :household_size => -3, :adult_age => 33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:household_size)
      end
    end

    context "adult_age" do
      it "cannot be negative" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => -33, :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:adult_age)
      end

      it "cannot be blank" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => "", :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:adult_age)
      end

      it "must be a number" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => "a", :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:adult_age)
      end

      it "can't be less than 18" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => "17", :spouse_age => "")
        test_calculation.should_not be_valid
        test_calculation.errors.should have(1).errors_on(:adult_age)
      end
    end

    context "spouse age" do
      it "must be a number" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => 33, :spouse_age => "a")
        test_calculation.should_not be_valid
        test_calculation.should have(1).errors_on(:spouse_age)
      end

      it "can be blank" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => 33, :spouse_age => "")
        test_calculation.should be_valid
        test_calculation.errors.should have(0).errors_on(:spouse_age)
      end

      it "can't be less than 18" do
        test_calculation = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 2, :adult_age => 33, :spouse_age => "17")
        test_calculation.should_not be_valid
        test_calculation.errors.should have(1).errors_on(:spouse_age)
      end

      #https://connectedhealth.atlassian.net/browse/CHUISCX-545
      it 'can be zero' do
        goal = SubsidyCalculations::Calculation.new(:household_income => "20,000", :household_size => 1, :adult_age => 33, :spouse_age => "0")
        expect(goal).to have(0).errors_on(:spouse_age)
      end
    end
  end

  describe "calculates max premium" do
    it "99 FPL, correctly" do
      expect(calculation.calculate_max_premium_percentage(99)).to eq(0.00)
    end

    it "133 FPL, correctly" do
      expect(calculation.calculate_max_premium_percentage(133)).to eq((3 + (0 * 0.059)).round(2))
    end

    it "143 FPL, correctly" do
      expect(calculation.calculate_max_premium_percentage(143)).to eq((3 + (10 * 0.059)).round(2))
    end

    it "150 FPL, correctly" do
      expect(calculation.calculate_max_premium_percentage(150)).to eq((4 + (0 * 0.046)).round(2))
    end

    it "167 FPL, correctly" do
      expect(calculation.calculate_max_premium_percentage(167)).to eq((4 + (17 * 0.046)).round(2))
    end

    it "300 FPL, correctly" do
      expect(calculation.calculate_max_premium_percentage(300)).to eq(9.50)
    end

    it "143 FPL, incorrectly" do
      expect(calculation.calculate_max_premium_percentage(143)).not_to eq(3.60)
    end
  end

  describe "calculates family premium estimate" do
    it "1 adult age 33" do
      calculation.adult_age = '33'
      expect(calculation.calculate_family_premium_estimate).to eq(262)
    end

    it "1 adult age 30 and 1 child age 20" do
      calculation.adult_age = '30'
      calculation.younger_children = '1'
      expect(calculation.calculate_family_premium_estimate).to eq(248 + 139)
    end

    it "1 adult age 30 and 1 child age 21" do
      calculation.adult_age = '30'
      calculation.spouse_age = '0'
      calculation.older_children = '1'
      expect(calculation.calculate_family_premium_estimate).to eq(248 + 219)
    end

    it "1 adult and spouse" do
      calculation.adult_age = '30'
      calculation.spouse_age = '33'
      expect(calculation.calculate_family_premium_estimate).to eq(248 + 262)
    end

    it "1 adult (30), spouse (33), and 1 young child" do
      calculation.adult_age = '30'
      calculation.spouse_age = '33'
      calculation.younger_children = '1'
      expect(calculation.calculate_family_premium_estimate).to eq(248 + 262 + 139)
    end

    it "1 adult (30), spouse (33), and 2 children (19 & 18)" do
      calculation.adult_age = '30'
      calculation.spouse_age = '33'
      calculation.younger_children = '2'
      expect(calculation.calculate_family_premium_estimate).to eq(248 + 262 + 139 + 139)
    end

    it "1 adult (30), spouse (33), and 4 children under 21" do
      calculation.adult_age = '30'
      calculation.spouse_age = '33'
      calculation.older_children = '4'
      expect(calculation.calculate_family_premium_estimate).to eq(248 + 262 + 219 + 219 + 219 + 219)
    end
  end

  describe "calculates subsidy estimate for" do
    it "30_000 income, 2 adults, ages 30 and 33" do
      calculation = SubsidyCalculations::Calculation.new(
                                                          :household_size => 2,
                                                          :household_income => "30,000",
                                                          :adult_age => 30,
                                                          :spouse_age => 28
                                                        )
      calculation.perform_calculations
      expect(calculation.family_subsidy_estimate).to eq(336)
    end
  end

  context "#determine_output_message" do
    it "when eligible for eployer plan returns :employer_plan" do
      calculation.eligible_for_employer_plan = "1"
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:employer_plan)
    end

    it "when adult age is over 64, return :medicare" do
      calculation.adult_age = 65
      calculation.spouse_age = 33
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:medicare)
    end

    it "when spouse age is over 64, return :medicare" do
      calculation.adult_age = 60
      calculation.spouse_age = 70
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:medicare)
    end

    it "when fplp is 0, returns medicaid" do
      calculation.family_fpl_percentage = 0
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:medicaid)
    end

    it "when fplp is 99, returns medicaid" do
      calculation.family_fpl_percentage = 99
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:medicaid)
    end

    it "when fplp is 100, returns probably" do
      calculation.family_fpl_percentage = 100
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:probably)
    end

    it "when fplp is 300, returns probably" do
      calculation.family_fpl_percentage = 300
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:probably)
    end

    it "when fplp is 301, returns maybe" do
      calculation.family_fpl_percentage = 301
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:maybe)
    end

    it "when fplp is 500, returns maybe" do
      calculation.family_fpl_percentage = 500
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:maybe)
    end

    it "when fplp is 501, returns probably_not" do
      calculation.family_fpl_percentage = 501
      output_symbol = calculation.send(:determine_output_message)
      expect(output_symbol).to eq(:probably_not)
    end
  end

  # JIRA 1108: Subsidy Calc - # of people in household s/not be < than total of enrollees
  describe "household_size should never be less than enrollees size" do

    describe "#enrollees_size method returns correct size when" do
      it "there are no enrolless" do
        expect(calculation.send(:enrollees_size)).to eq(0)
      end

      it "when there is just an adult age" do
        calculation.adult_age = "34"
        expect(calculation.send(:enrollees_size)).to eq(1)
      end

      it "when there is adult and spouse" do
        calculation.adult_age = "34"
        calculation.spouse_age = "34"
        expect(calculation.send(:enrollees_size)).to eq(2)
      end

      it "there is adult age but spouse is zero" do
        calculation.adult_age = "34"
        calculation.spouse_age = "0"
        expect(calculation.send(:enrollees_size)).to eq(1)
      end

      it "when there is adult and spouse and younger children" do
        calculation.adult_age = "34"
        calculation.spouse_age = "34"
        calculation.younger_children = "2"
        expect(calculation.send(:enrollees_size)).to eq(4)
      end

      it "when there is adult and spouse and 2 younger children and 2 older children" do
        calculation.adult_age = "34"
        calculation.spouse_age = "34"
        calculation.younger_children = "2"
        calculation.older_children = "2"
        expect(calculation.send(:enrollees_size)).to eq(6)
      end
    end

    #JIRA 1108/AC-1
    it "when enrollees size is higher than household_size" do
      calculation.household_size = "3"
      calculation.adult_age = "35"
      calculation.spouse_age = "33"
      calculation.younger_children = "2"
      calculation.older_children = "1"

      calculation.perform_calculations

      expect(calculation.household_size.to_i).to eq(5)
    end

    #JIRA 1108/AC-2
    it "when user enters 0 for spouse_age or children count" do
      calculation.household_size = "3"
      calculation.adult_age = "35"
      calculation.spouse_age = "0"
      calculation.younger_children = "2"
      calculation.older_children = "0"

      calculation.perform_calculations

      expect(calculation.household_size.to_i).to eq(3)
    end

    #JIRA 1108/AC-3
    it "when household_size is higher than enrollees size" do
      calculation.household_size = "7"
      calculation.adult_age = "35"
      calculation.spouse_age = "0"
      calculation.younger_children = "2"
      calculation.older_children = "0"

      calculation.perform_calculations

      expect(calculation.household_size.to_i).to eq(7)
    end
  end
end
