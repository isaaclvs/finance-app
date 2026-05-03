require "rails_helper"

RSpec.describe Import::TransactionsCsvParser do
  describe "#call" do
    it "parses valid CSV rows" do
      csv = <<~CSV
        date,amount,type,category,description,tags
        2026-05-01,100.50,income,Salary,Paycheck,work
      CSV

      result = described_class.new(file: StringIO.new(csv)).call

      expect(result[:file_error]).to be_nil
      expect(result[:row_errors]).to be_empty
      expect(result[:rows].size).to eq(1)
      expect(result[:rows].first[:transaction_type]).to eq("income")
      expect(result[:rows].first[:category_name]).to eq("Salary")
    end

    it "returns header error when required headers are missing" do
      csv = <<~CSV
        date,amount,type
        2026-05-01,100.50,income
      CSV

      result = described_class.new(file: StringIO.new(csv)).call

      expect(result[:file_error]).to include("category")
    end

    it "collects row errors for invalid values" do
      csv = <<~CSV
        date,amount,type,category,description
        invalid,0,unknown,,Broken row
      CSV

      result = described_class.new(file: StringIO.new(csv)).call

      expect(result[:row_errors].size).to eq(1)
      expect(result[:rows]).to be_empty
    end
  end
end
