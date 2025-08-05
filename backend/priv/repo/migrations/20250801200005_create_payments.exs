/*
  # Create payments table

  1. New Tables
    - `payments`
      - `id` (uuid, primary key)
      - `booking_id` (uuid, foreign key)
      - `stripe_payment_intent_id` (text)
      - `amount` (decimal, required)
      - `currency` (text, default 'EGP')
      - `status` (text, default 'pending')
      - `payment_method` (text)
      - `failure_reason` (text)
      - `metadata` (jsonb)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `payments` table
    - Add policies for booking participants to access payment info
*/

defmodule TagzUp.Repo.Migrations.CreatePayments do
  use Ecto.Migration

  def up do
    create table(:payments, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :booking_id, references(:bookings, type: :uuid, on_delete: :restrict), null: false
      add :stripe_payment_intent_id, :text
      add :amount, :decimal, precision: 10, scale: 2, null: false
      add :currency, :text, default: "EGP"
      add :status, :text, default: "pending"
      add :payment_method, :text
      add :failure_reason, :text
      add :metadata, :map

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create index(:payments, [:booking_id])
    create index(:payments, [:status])
    create index(:payments, [:stripe_payment_intent_id])

    alter table(:payments) do
      add_check_constraint(:status_check, 
        "status IN ('pending', 'processing', 'succeeded', 'failed', 'cancelled', 'refunded')")
    end

    execute "ALTER TABLE payments ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Booking participants can access payment info"
      ON payments
      FOR SELECT
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM bookings b
        JOIN business_profiles bp ON bp.id = b.business_profile_id
        JOIN influencer_profiles ip ON ip.id = b.influencer_profile_id
        JOIN users bu ON bu.id = bp.user_id
        JOIN users iu ON iu.id = ip.user_id
        WHERE b.id = payments.booking_id 
        AND (bu.id = auth.uid() OR iu.id = auth.uid())
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all payments"
      ON payments
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
    drop table(:payments)
  end
end