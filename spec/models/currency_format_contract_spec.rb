require "rails_helper"

RSpec.describe "Currency format contract" do
  it "keeps USD currency defaults for en" do
    formatted = I18n.with_locale(:en) do
      ActionController::Base.helpers.number_to_currency(1234.56)
    end

    expect(formatted).to eq("$1,234.56")
  end

  it "keeps BRL currency defaults for pt-BR" do
    formatted = I18n.with_locale(:"pt-BR") do
      ActionController::Base.helpers.number_to_currency(1234.56)
    end

    expect(formatted).to eq("R$ 1.234,56")
  end

  it "keeps negative BRL currency format" do
    formatted = I18n.with_locale(:"pt-BR") do
      ActionController::Base.helpers.number_to_currency(-10)
    end

    expect(formatted).to eq("-R$ 10,00")
  end
end
