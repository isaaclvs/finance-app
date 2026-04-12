class ReportsMailer < ApplicationMailer
  def monthly_summary(user, summary)
    @user = user
    @summary = summary

    mail(
      to: @user.email,
      subject: "Monthly financial report (#{@summary[:month]})"
    )
  end
end
