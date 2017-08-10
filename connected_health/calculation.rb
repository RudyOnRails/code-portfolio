module SubsidyCalculations

  class Calculation

    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    FPL_INCOME_OF_ONE_ADULT = 11_490
    FPL_INCOME_OF_EACH_ADDITIONAL_ADULT = 4_020

    CHILDREN_UNDER_21_CEILING = 3

    # http://www.cahba.com/assets_c/2013/06/Income%20Level%20Max%20Premium-843.htm
    TIERS = {
              1 => { :federal_poverty_level_percentage_lower => 0,   :federal_poverty_level_percentage_upper => 100, :premium_percent_lower => 0,    :premium_percent_upper => 0    },
              2 => { :federal_poverty_level_percentage_lower => 100, :federal_poverty_level_percentage_upper => 133, :premium_percent_lower => 2,    :premium_percent_upper => 2    },
              3 => { :federal_poverty_level_percentage_lower => 133, :federal_poverty_level_percentage_upper => 150, :premium_percent_lower => 3,    :premium_percent_upper => 4    },
              4 => { :federal_poverty_level_percentage_lower => 150, :federal_poverty_level_percentage_upper => 200, :premium_percent_lower => 4,    :premium_percent_upper => 6.3  },
              5 => { :federal_poverty_level_percentage_lower => 200, :federal_poverty_level_percentage_upper => 250, :premium_percent_lower => 6.3,  :premium_percent_upper => 8.05 },
              6 => { :federal_poverty_level_percentage_lower => 250, :federal_poverty_level_percentage_upper => 300, :premium_percent_lower => 8.05, :premium_percent_upper => 9.5  },
              7 => { :federal_poverty_level_percentage_lower => 300, :federal_poverty_level_percentage_upper => 400, :premium_percent_lower => 9.5,  :premium_percent_upper => 9.5  }
            }


    # These keys and values (age => monthly_premium_estimate) were
    # derived from http://laborcenter.berkeley.edu/healthpolicy/calculator/
    PREMIUM_ESTIMATES = {
                          "younger_children" => 139,
                          "older_children" => 219,
                                  25 => 220,
                                  26 => 224,
                                  27 => 229,
                                  28 => 238,
                                  29 => 245,
                                  30 => 248,
                                  31 => 253,
                                  32 => 259,
                                  33 => 262,
                                  34 => 266,
                                  35 => 267,
                                  36 => 269,
                                  37 => 271,
                                  38 => 273,
                                  39 => 276,
                                  40 => 280,
                                  41 => 285,
                                  42 => 290,
                                  43 => 297,
                                  44 => 306,
                                  45 => 316,
                                  46 => 328,
                                  47 => 342,
                                  48 => 358,
                                  49 => 373,
                                  50 => 391,
                                  51 => 408,
                                  52 => 427,
                                  53 => 446,
                                  54 => 467,
                                  55 => 488,
                                  56 => 510,
                                  57 => 533,
                                  58 => 557,
                                  59 => 569,
                                  60 => 594,
                                  61 => 615,
                                  62 => 628,
                                  63 => 646,
                                  64 => 656
                        }

    attr_accessor :household_income, :household_size, :adult_age, :spouse_age, :younger_children, :older_children, :eligible_for_employer_plan, :new_flag,
                  :family_fpl_percentage, :max_premium, :estimated_family_premium, :family_subsidy_estimate, :output_message_label

    validates :household_income, :presence => true
    validates :household_income, :allow_blank => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 0 }
    validates :household_size, :presence => true
    validates :household_size, :allow_blank => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 1 }
    validates :adult_age, :presence => true
    validates :adult_age, :allow_blank => true, :numericality => { :only_integer => true, :greater_than_or_equal_to => 18 }
    validates :spouse_age, :numericality => { :only_integer => true, :greater_than_or_equal_to => 18 }, :allow_blank => true, :if => :spouse_age_not_zero?

    def spouse_age_not_zero?
      @spouse_age != "0"
    end


    # TODO: set validations for :younger_children and :older_children

    def initialize(attributes = {})
      attributes.each do |name, value|
        send("#{name}=", value)
      end
    end

    def self.build_from_family(family, effective_date)
      calc = self.new
      calc.household_size = family.members_count
      calc.adult_age = family.applicant.age(effective_date)  if family.applicant.present?
      calc.spouse_age = family.spouse.age(effective_date) if family.spouse.present? && !family.spouse.beneficiary_only?
      children = family.children.reject(&:beneficiary_only?)
      if children.present?
        calc.younger_children = children.select { |c| c.age(effective_date) < 21 }.length
        calc.older_children =  children.length - calc.younger_children
      end
      calc.eligible_for_employer_plan = false
      calc.household_income = family.household_income.to_s
      calc
    end

    def persisted?
      false
    end

    def household_income=(value)
      @household_income = value.gsub(",", "")
    end

    def perform_calculations
      #step 0
      adjust_household_size_if_needed

      # step 1 - calculate Federal Poverty Level %
      @family_fpl_percentage = calculate_fpl_percentage(@household_size, @household_income)

      # step 2 - calculate max premium to pay if the FPLP is less than or equal to 400
      if @family_fpl_percentage <= TIERS[7][:federal_poverty_level_percentage_upper]
        @max_premium  = ((calculate_max_premium_percentage(@family_fpl_percentage)/100) * @household_income.to_i/12).round
      end

      # step 3 - calculate estimated household premium
      @estimated_family_premium = calculate_family_premium_estimate

      if @family_fpl_percentage > TIERS[7][:federal_poverty_level_percentage_upper]
        @max_premium = @estimated_family_premium
      end

      # step 4 - calculate family subsidy estimate
      @family_subsidy_estimate = calculate_family_subsidy_estimate

      # figure out text to give user direction
      @output_message_label = determine_output_message
    end

    def calculate_fpl_percentage(household_size, household_income)
      family_fpl = FPL_INCOME_OF_ONE_ADULT + (household_size.to_i - 1) * FPL_INCOME_OF_EACH_ADDITIONAL_ADULT
      ((household_income.to_f/family_fpl.to_f) * 100).to_i
    end

    def calculate_max_premium_percentage(fplp)
      tier_number = get_tier_for(fplp)
      get_max_premium_percentage(fplp, tier_number)
    end

    def calculate_family_premium_estimate
      total_premium = 0
      ages = []
      ages << @adult_age
      ages << @spouse_age unless (@spouse_age == "") || (@spouse_age == nil) || (@spouse_age == '0')
      ages.each do |age|
        total_premium += monthly_premium_estimate_for_age(age.to_i)
      end
      total_premium += younger_children_estimate(@younger_children || 0)
      total_premium += (@older_children.to_i || 0) * PREMIUM_ESTIMATES["older_children"]
      total_premium
    end

    def calculate_family_subsidy_estimate
      if @estimated_family_premium > @max_premium
        (@estimated_family_premium - (@max_premium)).to_i
      else
        0
      end
    end

    def new_or_invalid?
      new_flag || !valid?
    end

    private
    # JIRA 1108: # of people in household s/not be < than total of enrollees
    def adjust_household_size_if_needed
      if enrollees_size > household_size.to_i
        @household_size = enrollees_size
      end
    end

    def enrollees_size
      n = 0

      if !adult_age.to_i.zero? then n += 1 end
      if !spouse_age.to_i.zero? then n += 1 end
      n += younger_children.to_i
      n += older_children.to_i

      n
    end

    def younger_children_estimate(kids_arg)
      kids = kids_arg.to_i
      if kids == 0
        0
      elsif kids.between?(1,2)
        kids * PREMIUM_ESTIMATES["younger_children"]
      else
        CHILDREN_UNDER_21_CEILING * PREMIUM_ESTIMATES["younger_children"]
      end
    end

    def get_tier_for(fplp)
      case fplp
      when TIERS[1][:federal_poverty_level_percentage_lower]...TIERS[1][:federal_poverty_level_percentage_upper] then 1
      when TIERS[2][:federal_poverty_level_percentage_lower]...TIERS[2][:federal_poverty_level_percentage_upper] then 2
      when TIERS[3][:federal_poverty_level_percentage_lower]...TIERS[3][:federal_poverty_level_percentage_upper] then 3
      when TIERS[4][:federal_poverty_level_percentage_lower]...TIERS[4][:federal_poverty_level_percentage_upper] then 4
      when TIERS[5][:federal_poverty_level_percentage_lower]...TIERS[5][:federal_poverty_level_percentage_upper] then 5
      when TIERS[6][:federal_poverty_level_percentage_lower]...TIERS[6][:federal_poverty_level_percentage_upper] then 6
      when TIERS[7][:federal_poverty_level_percentage_lower]..TIERS[7][:federal_poverty_level_percentage_upper] then 7
      end
    end

    def get_max_premium_percentage(fplp, tier_number)
      tier = TIERS[tier_number]
      federal_poverty_level_percentage_spread = tier[:federal_poverty_level_percentage_upper] - tier[:federal_poverty_level_percentage_lower]
      premium_percentage_spread = tier[:premium_percent_upper] - tier[:premium_percent_lower]
      increment = premium_percentage_spread.to_f / federal_poverty_level_percentage_spread
      (tier[:premium_percent_lower] + ( (fplp - tier[:federal_poverty_level_percentage_lower]) * increment)).round(2)
    end

    def monthly_premium_estimate_for_age(age)
      if age < 21
        PREMIUM_ESTIMATES["younger_children"]
      elsif age.between?(21,24)
        PREMIUM_ESTIMATES["older_children"]
      elsif age.between?(25,64)
        PREMIUM_ESTIMATES[age]
      else
        864
      end
    end

    def determine_output_message
      if @eligible_for_employer_plan == "1"
        :employer_plan
      elsif (@adult_age.to_i >= 65) || (@spouse_age.to_i >= 65)
        :medicare
      elsif @family_fpl_percentage.between?(0, 99)
        :medicaid
      elsif @family_fpl_percentage.between?(100, 300)
        :probably
      elsif @family_fpl_percentage.between?(301, 500)
        :maybe
      else
        :probably_not
      end
    end
  end
end
