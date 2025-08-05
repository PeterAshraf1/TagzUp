/*
  # Create influencer profiles and related tables

  1. New Tables
    - `influencer_profiles`
      - `id` (uuid, primary key)
      - `user_id` (uuid, foreign key to users)
      - `display_name` (text, required)
      - `bio` (text)
      - `profile_image_url` (text)
      - `cover_image_url` (text)
      - `location` (text)
      - `languages` (text array)
      - `niches` (text array)
      - `total_followers` (integer, default 0)
      - `avg_engagement_rate` (decimal)
      - `verification_status` (text, default 'pending')
      - `is_featured` (boolean, default false)
      - `rating` (decimal)
      - `total_reviews` (integer, default 0)
      - `total_bookings` (integer, default 0)
      - `earnings` (decimal, default 0)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `influencer_profiles` table
    - Add policies for authenticated users to manage their own profiles
    - Add policies for public read access to verified profiles
*/

defmodule TagzUp.Repo.Migrations.CreateInfluencerProfiles do
  use Ecto.Migration

  def up do
    create table(:influencer_profiles, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false
      add :display_name, :text, null: false
      add :bio, :text
      add :profile_image_url, :text
      add :cover_image_url, :text
      add :location, :text
      add :languages, {:array, :text}, default: []
      add :niches, {:array, :text}, default: []
      add :total_followers, :integer, default: 0
      add :avg_engagement_rate, :decimal, precision: 5, scale: 2
      add :verification_status, :text, default: "pending"
      add :is_featured, :boolean, default: false
      add :rating, :decimal, precision: 3, scale: 2
      add :total_reviews, :integer, default: 0
      add :total_bookings, :integer, default: 0
      add :earnings, :decimal, precision: 12, scale: 2, default: 0

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create unique_index(:influencer_profiles, [:user_id])
    create index(:influencer_profiles, [:verification_status])
    create index(:influencer_profiles, [:is_featured])
    create index(:influencer_profiles, [:total_followers])
    create index(:influencer_profiles, [:rating])

    alter table(:influencer_profiles) do
      add_check_constraint(:verification_status_check, 
        "verification_status IN ('pending', 'verified', 'rejected')")
    end

    execute "ALTER TABLE influencer_profiles ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Users can read verified influencer profiles"
      ON influencer_profiles
      FOR SELECT
      TO authenticated
      USING (verification_status = 'verified')
    """

    execute """
    CREATE POLICY "Users can manage their own influencer profile"
      ON influencer_profiles
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM users 
        WHERE users.id = influencer_profiles.user_id 
        AND users.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all influencer profiles"
      ON influencer_profiles
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
    drop table(:influencer_profiles)
  end
end