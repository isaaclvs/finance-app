class EnablePgTrgmForTransactionSearch < ActiveRecord::Migration[8.0]
  def up
    enable_extension "pg_trgm" unless extension_enabled?("pg_trgm")

    execute <<~SQL
      CREATE INDEX index_transactions_on_description_trgm
      ON transactions
      USING gin (description gin_trgm_ops)
      WHERE description IS NOT NULL;
    SQL
  end

  def down
    execute <<~SQL
      DROP INDEX IF EXISTS index_transactions_on_description_trgm;
    SQL
  end
end
