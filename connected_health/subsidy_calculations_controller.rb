class SubsidyCalculationsController < ApplicationController
  def new

    if params[:subsidy_calculation]
      @calculation = SubsidyCalculations::Calculation.new(params[:subsidy_calculation])
      if @calculation.valid?
        @calculation.perform_calculations
        if recent_family
          recent_family.update_attributes!(
            household_income: @calculation.household_income,
            subsidy_estimate: @calculation.family_subsidy_estimate,
            zip_not_required: true
          )
        end
      end
    else
      @calculation =
        if recent_family
          effective_date = Date.parse(params[:effective_date]) if params[:effective_date]
          SubsidyCalculations::Calculation.build_from_family(recent_family, effective_date)
        else
          SubsidyCalculations::Calculation.new
        end
      @calculation.new_flag = true
    end

  end

  def create
    redirect_to new_subsidy_calculation_path(params)
  end

  private

  def recent_family
    @recent_family ||= Querying::Family.find_by_id(session[:most_recent_family_id])
  end
end
