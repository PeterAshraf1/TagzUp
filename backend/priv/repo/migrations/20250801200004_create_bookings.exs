/*
  # Create bookings table

  1. New Tables
    - `bookings`
      - `id` (uuid, primary key)
      - `business_profile_id` (uuid, foreign key)
      - `influencer_profile_id` (uuid, foreign key)
      - `package_id` (uuid, foreign key)
      - `status` (text, default 'pending_payment')
      - `total_amount` (decimal, required)
      - `platform_fee` (decimal, required)
      - `influencer_amount` (decimal, required)
      - `currency` (text, default 'EGP')
      - `brief` (text)
      - `requirements` (text)
      - `deadline` (timestamptz)
      - `started_at` (timestamptz)
      - `completed_at` (timestamptz)
      - `cancelled_at` (timestamptz)
      - `cancellation_reason` (text)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `bookings` table
    - Add policies for businesses and influencers to access their own bookings
*/

defmodule TagzUp.Repo.Migrations.CreateBookings do
  use Ecto.Migration

  def up do
    create table(:bookings, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :business_profile_id, references(:business_profiles, type: :uuid, on_delete: :restrict), null: false
      add :influencer_profile_id, references(:influencer_profiles, type: :uuid, on_delete: :restrict), null: false
      add :package_id, references(:packages, type: :uuid, on_delete: :restrict), null: false
      add :status, :text, default: "pending_payment"
      add :total_amount, :decimal, precision: 10, scale: 2, null: false
      add :platform_fee, :decimal, precision: 10, scale: 2, null: false
      add :influencer_amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :text, default: "EGP"
      add :brief, :text
      add :requirements, :text
      add :deadline, :utc_datetime_usec
      add :started_at, :utc_datetime_usec
      add :completed_at, :utc_datetime_usec
      add :cancelled_at, :utc_datetime_usec
      add :cancellation_reason, :text

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create index(:bookings, [:business_profile_id])
    create index(:bookings, [:influencer_profile_id])
    create index(:bookings, [:package_id])
    create index(:bookings, [:status])
    create index(:bookings, [:created_at])

    alter table(:bookings) do
      add_check_constraint(:status_check, 
        "status IN ('pending_payment', 'paid', 'in_progress', 'pending_proof', 'pending_verification', 'completed', 'cancelled', 'disputed')")
    end

    execute "ALTER TABLE bookings ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Businesses can access their own bookings"
      ON bookings
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM business_profiles bp
        JOIN users u ON u.id = bp.user_id
        WHERE bp.id = bookings.business_profile_id 
        AND u.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Influencers can access their own bookings"
      ON bookings
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM influencer_profiles ip
        JOIN users u ON u.id = ip.user_id
        WHERE ip.id = bookings.influencer_profile_id 
        AND u.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all bookings"
      ON bookings
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
    drop table(:bookings)
  end
end