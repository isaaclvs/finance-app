require "rails_helper"

RSpec.describe "Currency format contract" do
  it "keeps BRL currency defaults" do
    formatted = ActionController::Base.helpers.number_to_currency(1234.56)

    expect(formatted).to eq("R$ 1.234,56")
  end

  it "keeps negative BRL currency format" do
    formatted = ActionController::Base.helpers.number_to_currency(-10)

    expect(formatted).to eq("-R$ 10,00")
  end
end
