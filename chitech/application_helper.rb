module ApplicationHelper
  def title
    prepend = "DEV: " if Rails.env == "development"
    chitech = "Chicago Tech Academy"
    prepend ? prepend + chitech : chitech
  end
end
