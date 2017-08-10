module SubsidyCalculatorHelper


  def generate_output_message_for_label(val)
    default_output_messages = {
                      :employer_plan => "Employees who are offered employer coverage are not eligible for subsidized coverage unless their income is between 1 and 4 times the federal poverty level, and the employee's contribution to the employer's coverage is more than 9.5% of your household income.",
                      :medicaid => "You may be eligible for your state's Medicaid program. Contact your state's Medicaid program regarding eligibility and enrollment.",
                      :probably => "You are probably eligible for a subsidy. To officially determine your eligibility visit the #{ link_to 'Federally Facilitated Marketplace', "https://www.healthcare.gov/", :target => '_blank' }.",
                      :maybe => "You may be eligible for a subsidy. To officially determine your eligibility visit the #{ link_to 'Federally Facilitated Marketplace', "https://www.healthcare.gov/", :target => '_blank' }.",
                      :probably_not => "You are probably not eligible for a subsidy.",
                      :medicare => "Based on the age(s) (65+) you entered, those members may be eligible for Medicare.  For more information about Medicare, visit #{ link_to 'medicare.gov', "http://medicare.gov/", :target => '_blank' }."
                    }

    default_output_messages[val].try(:html_safe)
  end
end
