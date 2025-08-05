/*
  # Create business profiles table

  1. New Tables
    - `business_profiles`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `company_name` (text, required)
      - `industry` (text)
      - `website_url` (text)
      - `logo_url` (text)
      - `description` (text)
      - `location` (text)
      - `company_size` (text)
      - `verification_status` (text, default 'pending')
      - `total_campaigns` (integer, default 0)
      - `total_spent` (decimal, default 0)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `business_profiles` table
    - Add policies for businesses to manage their own profiles
    - Add policies for public read access to verified profiles
*/

defmodule TagzUp.Repo.Migrations.CreateBusinessProfiles do
  use Ecto.Migration

  def up do
    create table(:business_profiles, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :company_name, :text, null: false
      add :industry, :text
      add :website_url, :text
      add :logo_url, :text
      add :description, :text
      add :location, :text
      add :company_size, :text
      add :verification_status, :text, default: "pending"
      add :total_campaigns, :integer, default: 0
      add :total_spent, :decimal, precision: 12, scale: 2, default: 0

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create unique_index(:business_profiles, [:user_id])
    create index(:business_profiles, [:verification_status])
    create index(:business_profiles, [:industry])
    create index(:business_profiles, [:company_size])

    alter table(:business_profiles) do
      add_check_constraint(:verification_status_check, 
        "verification_status IN ('pending', 'verified', 'rejected')")
      add_check_constraint(:company_size_check, 
        "company_size IN ('startup', 'small', 'medium', 'large', 'enterprise')")
    end

    execute "ALTER TABLE business_profiles ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Users can read verified business profiles"
      ON business_profiles
      FOR SELECT
      TO authenticated
      USING (verification_status = 'verified')
    """

    execute """
    CREATE POLICY "Users can manage their own business profile"
      ON business_profiles
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = business_profiles.user_id 
        AND users.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all business profiles"
      ON business_profiles
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = auth.uid() 
        AND users.user_type = 'admin'
      ))
    """
  end

  def down do
    drop table(:business_profiles)
  end
end