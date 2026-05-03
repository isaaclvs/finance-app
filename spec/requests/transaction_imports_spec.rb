require "rails_helper"

RSpec.describe "Transaction imports", type: :request do
  let(:user) { create(:user) }
  let(:category) { create(:category, user: user, name: "Food") }

  before do
    sign_in_user(user)
  end

  def uploaded_csv(content, filename: "tx.csv")
    file = Tempfile.new([ "import", ".csv" ])
    file.write(content)
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "text/csv", original_filename: filename)
  end

  it "shows preview before persisting transactions" do
    csv = <<~CSV
      date,amount,type,category,description,tags
      2026-05-01,20.00,expense,Food,Lunch,meal
    CSV

    expect do
      post preview_transaction_imports_path, params: {
        import: {
          file: uploaded_csv(csv)
        }
      }
    end.not_to change(Transaction, :count)

    expect(response).to have_http_status(:ok)
    expect(response.body).to include(I18n.t("transaction_imports.preview.title"))
  end

  it "does not import duplicates against existing transactions" do
    create(:transaction,
           user: user,
           category: category,
           amount: 20,
           transaction_type: "expense",
           date: Date.new(2026, 5, 1),
           description: "Lunch")

    csv = <<~CSV
      date,amount,type,category,description,tags
      2026-05-01,20.00,expense,Food,Lunch,
    CSV

    post preview_transaction_imports_path, params: {
      import: {
        file: uploaded_csv(csv)
      }
    }

    expect do
      post transaction_imports_path
    end.not_to change(Transaction, :count)

    follow_redirect!
    expect(response.body).to include("0")
  end

  it "returns clear feedback for invalid CSV format" do
    csv = "not_a_csv"

    post preview_transaction_imports_path, params: {
      import: {
        file: uploaded_csv(csv, filename: "broken.csv")
      }
    }

    expect(response).to redirect_to(new_transaction_import_path)
    follow_redirect!
    expect(response.body).to include(I18n.t("transaction_imports.errors.invalid_csv"))
  end
end
