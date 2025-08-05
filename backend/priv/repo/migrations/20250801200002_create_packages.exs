/*
  # Create packages table

  1. New Tables
    - `packages`
      - `id` (uuid, primary key)
      - `influencer_profile_id` (uuid, foreign key)
      - `title` (text, required)
      - `description` (text)
      - `platforms` (text array, required)
      - `deliverables` (text array, required)
      - `price` (decimal, required)
      - `currency` (text, default 'EGP')
      - `delivery_time_days` (integer, required)
      - `revisions_included` (integer, default 1)
      - `post_duration_hours` (integer)
      - `is_active` (boolean, default true)
      - `requirements` (text)
      - `sample_work_urls` (text array)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `packages` table
    - Add policies for public read access to active packages
    - Add policies for influencers to manage their own packages
*/

defmodule TagzUp.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def up do
    create table(:packages, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :influencer_profile_id, references(:influencer_profiles, type: :uuid, on_delete: :delete_all), null: false
      add :title, :text, null: false
      add :description, :text
      add :platforms, {:array, :text}, null: false
      add :deliverables, {:array, :text}, null: false
      add :price, :decimal, precision: 10, scale: 2, null: false
      add :currency, :text, default: "EGP"
      add :delivery_time_days, :integer, null: false
      add :revisions_included, :integer, default: 1
      add :post_duration_hours, :integer
      add :is_active, :boolean, default: true
      add :requirements, :text
      add :sample_work_urls, {:array, :text}, default: []

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create index(:packages, [:influencer_profile_id])
    create index(:packages, [:is_active])
    create index(:packages, [:price])
    create index(:packages, [:platforms], using: :gin)

    execute "ALTER TABLE packages ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Users can read active packages from verified influencers"
      ON packages
      FOR SELECT
      TO authenticated
      USING (
        is_active = true AND
        EXISTS (
          SELECT 1 FROM influencer_profiles ip
          WHERE ip.id = packages.influencer_profile_id 
          AND ip.verification_status = 'verified'
        )
      )
    """

    execute """
    CREATE POLICY "Influencers can manage their own packages"
      ON packages
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM influencer_profiles ip
        JOIN users u ON u.id = ip.user_id
        WHERE ip.id = packages.influencer_profile_id 
        AND u.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all packages"
      ON packages
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
    drop table(:packages)
  end
end