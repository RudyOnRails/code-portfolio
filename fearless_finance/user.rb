class User < ActiveRecord::Base  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  after_create :send_welcome_email

  validates_presence_of [:email, :first_name, :last_name, :age, :phone], on: :update

  has_many :expenses, dependent: :destroy
  has_many :expense_categories, through: :expenses
  has_many :kids, dependent: :destroy
  has_many :estimates, dependent: :destroy
  has_many :annual_need_estimates, dependent: :destroy
  has_many :savings_accounts, dependent: :destroy
  has_many :debts, dependent: :destroy
  has_many :retirement_expenses, dependent: :destroy
  has_many :financial_goals, dependent: :destroy

  enum payment_frequency: {every_week: 0, every_2_weeks: 1, every_month: 2, every_year: 3}
  enum spouse_payment_frequency: {spouse_every_week: 0, spouse_every_2_weeks: 1, spouse_every_month: 2, spouse_every_year: 3}
  enum additional_income_frequency: {ai_every_2_weeks: 0, ai_every_month: 2, ai_every_quarter: 3, ai_every_6_months: 4, ai_every_year: 5, ai_occasionally: 6}
  enum pension_type: {per_month: 0, per_year: 1}
  enum college_preference: {state_school: 0, private_school: 1, no_college: 3}
  enum cover_spouse_or_children: {children: 0, spouse: 1}

  ########### BUYING A NEW HOUSE ###############

  def current_payment
      if homeowner
        sum = expenses.select{|e| e.expense_category.name == 'Mortgage'}.map(&:amount).inject(:+).to_i
      else
        sum = expenses.select{|e| e.expense_category.name == 'Rent'}.map(&:amount).inject(:+).to_i
      end
  end

  def hoa_payment

  end



  def current_home_equity
    current_home_value = savings_accounts.current_home_value.sum(:total)
    still_owed = debts.mortgage.sum(:amount_owed)

    current_equity = current_home_value - still_owed
    return current_equity

  end


  ##############################################


  ########### THE CASCADE OF DOOM ################

  def passes_cascade?
    rainy_day_savings_filled? && emergency_savings_filled? && meeting_retirement_contribution?
  end

  def new_months_needed_to_fill_es(funds)
    needed = emergency_savings_needed - (liquid_savings-rainy_day_savings_needed)
    months = needed / funds

    return months.round(0).to_i
  end

  def new_months_needed_to_pay_cc(funds)
    needed = cc_debt
    months = needed / funds

    return months.round(0).to_i
  end


  def months_to_fill_first_month_emergency_savings
    needed = monthly_expense - (liquid_savings - rainy_day_savings_needed)

    months = (needed / current_remaining_money).round(0)

    return months

  end

  def new_remaining_money # Remaining For Goals, not RLS (Remaining Liquid Savings)
    # ADJUSTED WITH NEW RETIREMENT CONTRIBUTION
    take_home_pay_after_tax - monthly_expense - cushion - new_monthly_retirement_contribution
  end

  def work_less_remaining_money(income)
    income - monthly_expense - cushion - new_monthly_retirement_contribution
  end

  def current_remaining_money
    monthly_income - monthly_expense - cushion
  end


  # def new_take_home_pay
  #   percent_of_income_after_tax * (pre_tax_monthly_income*(1-0.15))
  # end


  def es_needed_per_month
    new_remaining_money

    return [per_month, months_to_fill]
  end

  def months_to_fill_rds
    months = (rainy_day_savings_needed-liquid_savings)/current_remaining_money
    return months.round(0)
  end

  def cushion
    if married? || number_of_kids > 0 || homeowner?
      return 400
    else
      return 300
    end
  end

  def meeting_retirement_contribution?
    return false if !yearly_retirement_contribution
    if age <= 30
        if yearly_retirement_contribution >= 10
          return true
        else
          return false
        end
    elsif age > 30 && age <= 40
      if qualified_savings <= 200000
        if yearly_retirement_contribution >= 20
          return true
        else
          return false
        end
      else
        if yearly_retirement_contribution >= 15
          return true
        else
          return false
        end
      end
    elsif age > 40
      if qualified_savings <= 450000
        if yearly_retirement_contribution >= 20
          return true
        else
          return false
        end
      else
        if yearly_retirement_contribution >= 15
          return true
        else
          return false
        end
      end
    end

  end

  def new_monthly_retirement_contribution
    if meeting_retirement_contribution?
      return 0
    else
      if age <= 30
        rate = 10 - retirement_contribution
      elsif age > 30 && age <= 45
        if qualified_savings <= 200000
          rate = 20 - retirement_contribution
        else
          rate = 15 - retirement_contribution
        end
      elsif age > 45
        if qualified_savings <= 650000
          rate = 20 - retirement_contribution
        else
          rate = 15 - retirement_contribution
        end
      end

      return (rate/100) * take_home_pay_before_tax
    end
  end

  ################################################

  ########### RETIREMENT #########################

  def retirement_deficit_surplus
    retirement_amount_saved - retirement_amount_required
  end

  def retirement_amount_saved
    inflation_rate = inflation_rate
    growth_rate = GrowthRate.first.rate/100.00
    tax_rate = retirement_tax_rate/100.00

    starting_total = qualified_savings + non_qualified_savings
    year = 0
    npv_array = []
    current_age = retirement_age

    while year <= (years_until_retirement-1) do
        adjusted_total = starting_total * (1+growth_rate)
      if inheritance?
        if age+year == inheritance_age
          adjusted_total = adjusted_total + inheritance_amount
        end
      end

      if year == 0
        npv_array << adjusted_total
        starting_total = adjusted_total
      else
        npv_array << adjusted_total+yearly_retirement_contribution
        starting_total = adjusted_total + yearly_retirement_contribution
      end
      current_age += 1
      year += 1
    end

    return npv_array.last.to_i
  end

  def retirement_amount_required

    inflation_rate = InflationRate.first.rate/100.00
    growth_rate = GrowthRate.first.rate/100.00
    tax_rate = retirement_tax_rate/100.00

    inflated_amount_needed = yearly_amount_needed_in_retirement * ((1+inflation_rate)**years_until_retirement)
    inflated_pension = yearly_pension * ((1+inflation_rate)**years_until_retirement) if pension?
    inflated_ss = yearly_ss_benefit * ((1+inflation_rate)**years_until_retirement) if monthly_ss_benefit?


    starting_total_at_retirement = inflated_amount_needed
    starting_total_at_retirement = starting_total_at_retirement - inflated_pension if inflated_pension.present?
    starting_total_at_retirement = starting_total_at_retirement - inflated_ss if inflated_ss.present?

    year = 0
    npv_array = []
    while year <= years_in_retirement do
      inflated_total = starting_total_at_retirement * ((1+inflation_rate)**year)

      npv_array << inflated_total / (1-tax_rate)
      year += 1
    end

    return npv_array.npv(growth_rate).to_i

  end

  def monthly_retirement_contribution
    retirement_contribution / 12
  end

  def yearly_amount_needed_in_retirement
    retirement_monthly_cost * 12
  end

  def yearly_pension
    pension_amount*12
  end

  def yearly_ss_benefit
    monthly_ss_benefit*12
  end

  def years_in_retirement
    life_expectancy - retirement_age
  end

  def qualified_savings
    if savings_accounts.qualified_retirement.present?
      return savings_accounts.qualified_retirement.sum(:total)
    else
      return 0.00
    end
  end

  

  def non_qualified_savings
    if savings_accounts.liquid.present?
      return savings_accounts.liquid.sum(:total)
    else
      return 0.00
    end
  end

  def years_until_retirement
    retirement_age - age
  end

  def years_until_death
    life_expectancy - age
  end

################################################
  
  def total_cost_of_childcare(goal)
    goal.new_baby_childcare_cost * 24
  end
  

  def number_of_kids
    kids.count    
  end


  def net_present_value
    (retirement_contribution * (retirement_tax_rate/100)) * years_until_retirement
  end

  def overspending_in_category(c)
    if !c.hotspot.present?
      return false
    elsif (spending_for_category(c)/people_in_household) > c.hotspot
      return true
    end
  end

  def has_additional_income
    additional_income.present?
  end

  def blue_points
    blue_estimates = estimates.select{|e| e.expense_category.color_code == '#6699cc'}.map(&:amount)

    return blue_estimates.inject(:+)
  end

  def yellow_points
    yellow_estimates = estimates.select{|e| e.expense_category.color_code == '#ffcc00'}.map(&:amount)

    return yellow_estimates.inject(:+)
  end

  def green_points
    green_estimates = estimates.select{|e| e.expense_category.color_code == '#669966'}.map(&:amount)

    return green_estimates.inject(:+)
  end

  def debt_to_income
    monthly_debt = debts.sum(:cost_per_month)
    dti = monthly_debt / monthly_income

    return dti.round(2)*100
  end

  def monthly_income
    if every_week?
      monthly_income = take_home_pay_after_tax * 4
    elsif every_2_weeks?
      monthly_income = take_home_pay_after_tax * 2
    elsif every_month?
      monthly_income = take_home_pay_after_tax
    elsif every_year?
      monthly_income = take_home_pay_after_tax / 12
    end

    return monthly_income + spouse_monthly_income
  end

  def pre_tax_monthly_income
    if every_week?
      monthly_income = take_home_pay_before_tax * 4
    elsif every_2_weeks?
      monthly_income = take_home_pay_before_tax * 2
    elsif every_month?
      monthly_income = take_home_pay_before_tax
    elsif every_year?
      monthly_income = take_home_pay_before_tax / 12
    end

    return monthly_income
  end

  def spouse_monthly_income
    if spouse_take_home_pay_after_tax.present?
      if spouse_every_week?
        monthly_income = spouse_take_home_pay_after_tax * 4
      elsif spouse_every_2_weeks?
        monthly_income = spouse_take_home_pay_after_tax * 2
      elsif spouse_every_month?
        monthly_income = spouse_take_home_pay_after_tax
      elsif spouse_every_year?
        monthly_income = spouse_take_home_pay_after_tax / 12
      end
    else
      monthly_income = 0
    end

    return monthly_income
  end

  def net_worth
    total_savings - total_debt
  end

  def total_savings
    savings_accounts.sum(:total)
  end


  def total_debt
    debts.sum(:amount_owed)
  end

  def non_consumer_debt
    total_debt - cc_debt
  end

  def savings_after_buckets
    liquid_savings - emergency_savings_needed
  end

  def months_of_emergency_savings
    ((liquid_savings-rainy_day_savings_needed) / monthly_expense).round(0).to_i
  end

  def monthly_expense
    expenses.onboarding.sum(:amount).round(0) + monthly_annual_needs
  end

  def rainy_day_savings_needed
    if homeowner && number_of_kids > 0
      return 3000
    elsif !homeowner && number_of_kids > 0
      return 2000
    else
      return 1500
    end
  end

  def top_goal
    financial_goals.first
  end
  
  def secondary_goal
    financial_goals.first
  end

  def emergency_savings_filled?
    (liquid_savings - rainy_day_savings_needed) >= emergency_savings_needed
  end

  def rainy_day_savings_filled?
    liquid_savings >= rainy_day_savings_needed
  end

  def emergency_savings_needed 
    (monthly_expense * months_for_emergencies) + rainy_day_savings_needed
  end


  def spending_for_category(category)
    expenses.where(expense_category_id: category.id).sum(:amount)
  end

  def total_expenses
    expenses.sum(:amount)    
  end

  def liquid_savings
    if savings_accounts.liquid.present?
      return savings_accounts.liquid.sum(:total)
    else
      return 0
    end
  end

  def monthly_annual_needs
    annual_need_estimates.sum(:amount)/12
  end

  def percent_of_income_after_tax
    take_home_pay_after_tax/take_home_pay_before_tax
  end

  def consumer_debt
    cc_debt
  end

  def cc_debt
    if debts.credit_card.present?
      return debts.credit_card.sum(:amount_owed)
    else
      return 0
    end
  end

  def other_debt
    if debts.other.present?
      return debts.other.sum(:amount_owed)
    else
      return 0
    end
  end

  def estimate_for_category(category)
    estimates.find_by(expense_category_id: category.id)
  end

  def set_monthly_retirement  
    self.retirement_monthly_cost = self.retirement_expenses.sum(:amount)
    self.save
  end

  def savings_by_type
    grouped_savings = savings_accounts.group_by(&:savings_type)

    return grouped_savings
  end

  def years_until_retirement
    retirement_age - age
  end

  def annual_cost_of_college
    number_of_kids = kids.count
    number_of_kids * 30000
  end

  #   enum college_preference: {state_school: 0, private_school: 1, no_college: 3}

  def college_preference_cost
    case college_preference
      when "state_school"
        75_000
      when "private_school"
        150_000
      else
        0
    end
  end

  def saved_for_college
    kids.first.yrs_until_18 * 12 * current_remaining_money
  end

  def will_save_enough_for_college?
    case
      when saved_for_college > college_preference_cost
        true
      else
        false
    end
  end

  def kids_going_to_college?
    number_of_kids > 0 && kids.where(college: true).present?
  end

  def has_all_targets?
    expense_categories.each do |e|
      estimate_for_category(e).present?
    end
  end

  def retirement_contribution_percentage
    if meeting_retirement_contribution?
      return 100
    else
      if age <= 30
        rate = 10
      elsif age > 30 && age <= 45 
        if qualified_savings <= 200000
          rate = 20
        else
          rate = 15
        end      
      elsif age > 45
        if qualified_savings <= 650000
          rate = 20
        else
          rate = 15
        end
      end
      
      return (yearly_retirement_contribution/rate)*100
    end
  end

  def rds_filled_percentage
    if liquid_savings > rainy_day_savings_needed
      return 100
    else
      return  ((liquid_savings/rainy_day_savings_needed)*100).round(0).to_i
    end
  end

  def es_filled_percentage
    if liquid_savings > (rainy_day_savings_needed + emergency_savings_needed)
      return 100
    else
      return  (liquid_savings/(rainy_day_savings_needed + emergency_savings_needed).round(2)) * 100
    end
  end

######## CHECKING FOR ACCOUNT COMPLETION  ##################

  def profile_complete?
    personal_information_complete? && expenses.count > 0 && take_home_pay_after_tax.present? && payment_frequency.present? && months_for_emergencies.present? && blues >= 0
  end

  def personal_information_complete?
    first_name.present? && last_name.present? && phone.present? && dob.present?
  end

  def cash_flow_information_complete?
    take_home_pay_after_tax.present? && take_home_pay_before_tax.present? && payment_frequency.present? 
  end

  def expense_information_complete?
    expenses.count > 2
  end

  def target_information_complete?
    has_all_targets?
  end

  def annual_needs_complete?
    annual_need_estimates.count >= 1
  end

  def retirement_information_complete?
    if age < 30
      return true
    else
      retirement_age.present? && retirement_tax_rate.present?
    end
  end

  def exceeding_blue_point_limit?
    blue_points > 1500
     
  end

  def people_in_household
    peeps = 1
    peeps += 1  if married
    peeps += number_of_kids

    return peeps
  end

  def months_to_complete_goal(goal, money)
    if goal.use_savings_percentage
      cost = (goal.cost_to_complete - (goal.cost_to_complete * (goal.use_savings_percentage/100)))
    else
      cost = goal.cost_to_complete
    end
      
    months = cost/money
    return months.to_i
  end

  def can_complete_goal_on_time(goal)
    years = goal.years_to_complete
    months = years*12
    if (new_remaining_money * months) >= goal.cost_to_complete
      return true
    else
      return false
    end
  end

  def monthly_money_needed_from_savings_for_goal(goal)
    cost = goal.cost_to_complete
    months = goal.years_to_complete * 12
    funds = new_remaining_money * months

    needed_per_month = (cost - funds)/12
    if savings_after_buckets * (goal.use_savings_percentage/100) > needed_per_month
      return needed_per_month
    else
      return false
    end

  end

  def months_to_complete(cost, monthly_funds)
    months = cost/monthly_funds
    return months.round(0).to_i

  end

  def has_systemic_issue?    
    yellows = expenses.select{|e| e.expense_category.color_code == '#ffcc00'}.map(&:amount).inject(:+)
    yellows > (monthly_income*0.45)
  end

  def household_expenses
    yellows = expenses.select{|e| e.expense_category.color_code == '#ffcc00'}.map(&:amount).inject(:+)
    greens = expenses.select{|e| e.expense_category.color_code == '#669966'}.map(&:amount).inject(:+)
    return yellows + greens
  end

  def blues
    blues = expenses.this_month.select{|e| e.expense_category.color_code == '#6699cc'}.map(&:amount).inject(:+)
    if blues.present?
      blues
    else
      return 0.00
    end
  end

  def blue_point_limit
    if married && number_of_kids > 0
      limit = 1500
    elsif married
      limit = 1000
    else
      limit = 800
    end

    return limit
    
  end

  def over_blue_point_limit?
    blues > blue_point_limit
  end

  def blue_points_filled_percentage
    if blues > blue_points
      return 100
    else
      return (blues/blue_points)*100
    end

  end

  def retirement_contribution
    if yearly_retirement_contribution
      return yearly_retirement_contribution
    else
      return 0
    end
  end

  def age
    (Date.today.year - dob.year)
  end

  def paying_for_college?
    if number_of_kids < 1
      return false
    else
      return kids.where(college: true).count
    end
  end


  private

  def send_welcome_email
    UserMailer.signup_confirmation(self).deliver
  end

  
end
