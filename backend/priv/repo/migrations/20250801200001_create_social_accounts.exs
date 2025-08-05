/*
  # Create social accounts table

  1. New Tables
    - `social_accounts`
      - `id` (uuid, primary key)
      - `influencer_profile_id` (uuid, foreign key)
      - `platform` (text, required)
      - `username` (text, required)
      - `profile_url` (text, required)
      - `follower_count` (integer, default 0)
      - `engagement_rate` (decimal)
      - `verification_status` (text, default 'pending')
      - `last_verified_at` (timestamptz)
      - `api_data` (jsonb)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `social_accounts` table
    - Add policies for influencers to manage their own accounts
    - Add policies for public read access to verified accounts
*/

defmodule TagzUp.Repo.Migrations.CreateSocialAccounts do
  use Ecto.Migration

  def up do
    create table(:social_accounts, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :influencer_profile_id, references(:influencer_profiles, type: :uuid, on_delete: :delete_all), null: false
      add :platform, :text, null: false
      add :username, :text, null: false
      add :profile_url, :text, null: false
      add :follower_count, :integer, default: 0
      add :engagement_rate, :decimal, precision: 5, scale: 2
      add :verification_status, :text, default: "pending"
      add :last_verified_at, :utc_datetime_usec
      add :api_data, :map

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create unique_index(:social_accounts, [:influencer_profile_id, :platform])
    create index(:social_accounts, [:platform])
    create index(:social_accounts, [:verification_status])
    create index(:social_accounts, [:follower_count])

    alter table(:social_accounts) do
      add_check_constraint(:platform_check, 
        "platform IN ('instagram', 'tiktok', 'youtube', 'facebook', 'twitter', 'linkedin')")
      add_check_constraint(:verification_status_check, 
        "verification_status IN ('pending', 'verified', 'failed')")
    end

    execute "ALTER TABLE social_accounts ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Users can read verified social accounts"
      ON social_accounts
      FOR SELECT
      TO authenticated
      USING (verification_status = 'verified')
    """

    execute """
    CREATE POLICY "Influencers can manage their own social accounts"
      ON social_accounts
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM influencer_profiles ip
        JOIN users u ON u.id = ip.user_id
        WHERE ip.id = social_accounts.influencer_profile_id 
        AND u.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all social accounts"
      ON social_accounts
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
    drop table(:social_accounts)
  end
end