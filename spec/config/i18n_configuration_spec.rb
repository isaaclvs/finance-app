require "rails_helper"

RSpec.describe "I18n configuration" do
  it "uses pt-BR as the default locale" do
    expect(I18n.default_locale).to eq(:"pt-BR")
  end

  it "allows pt-BR and en locales" do
    expect(I18n.available_locales).to include(:"pt-BR", :en)
  end

  it "falls back to en when translation is missing" do
    expect(I18n.fallbacks[:"pt-BR"]).to include(:en)
  end
end
