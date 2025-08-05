/*
  # Create proofs table

  1. New Tables
    - `proofs`
      - `id` (uuid, primary key)
      - `booking_id` (uuid, foreign key)
      - `platform` (text, required)
      - `post_url` (text, required)
      - `screenshot_urls` (text array)
      - `post_id` (text)
      - `published_at` (timestamptz)
      - `verification_status` (text, default 'pending')
      - `verification_data` (jsonb)
      - `views_count` (integer)
      - `likes_count` (integer)
      - `comments_count` (integer)
      - `shares_count` (integer)
      - `verified_at` (timestamptz)
      - `verified_by_user_id` (uuid)
      - `notes` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `proofs` table
    - Add policies for booking participants to access proofs
*/

defmodule TagzUp.Repo.Migrations.CreateProofs do
  use Ecto.Migration

  def up do
    create table(:proofs, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :booking_id, references(:bookings, type: :uuid, on_delete: :delete_all), null: false
      add :platform, :text, null: false
      add :post_url, :text, null: false
      add :screenshot_urls, {:array, :text}, default: []
      add :post_id, :text
      add :published_at, :utc_datetime_usec
      add :verification_status, :text, default: "pending"
      add :verification_data, :map
      add :views_count, :integer
      add :likes_count, :integer
      add :comments_count, :integer
      add :shares_count, :integer
      add :verified_at, :utc_datetime_usec
      add :verified_by_user_id, references(:users, type: :uuid)
      add :notes, :text

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create index(:proofs, [:booking_id])
    create index(:proofs, [:platform])
    create index(:proofs, [:verification_status])
    create index(:proofs, [:published_at])

    alter table(:proofs) do
      add_check_constraint(:platform_check, 
        "platform IN ('instagram', 'tiktok', 'youtube', 'facebook', 'twitter', 'linkedin')")
      add_check_constraint(:verification_status_check, 
        "verification_status IN ('pending', 'auto_verified', 'manually_verified', 'failed', 'disputed')")
    end

    execute "ALTER TABLE proofs ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Booking participants can access proofs"
      ON proofs
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM bookings b
        JOIN business_profiles bp ON bp.id = b.business_profile_id
        JOIN influencer_profiles ip ON ip.id = b.influencer_profile_id
        JOIN users bu ON bu.id = bp.user_id
        JOIN users iu ON iu.id = ip.user_id
        WHERE b.id = proofs.booking_id 
        AND (bu.id = auth.uid() OR iu.id = auth.uid())
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all proofs"
      ON proofs
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
    drop table(:proofs)
  end
end