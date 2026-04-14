module ApplicationHelper
  def localized_date(date, format: :short)
    return "" if date.blank?

    I18n.l(date, format: format)
  end

  def currency_unit(strip: false)
    unit = I18n.t("number.currency.format.unit", default: "")
    strip ? unit.strip : unit
  end
end
