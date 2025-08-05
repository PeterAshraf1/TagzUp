/*
  # Create disputes table

  1. New Tables
    - `disputes`
      - `id` (uuid, primary key)
      - `booking_id` (uuid, foreign key)
      - `raised_by_user_id` (uuid, foreign key)
      - `reason` (text, required)
      - `description` (text, required)
      - `evidence_urls` (text array)
      - `status` (text, default 'open')
      - `resolution` (text)
      - `resolved_by_user_id` (uuid)
      - `resolved_at` (timestamptz)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `disputes` table
    - Add policies for dispute participants and admins to access disputes
*/

defmodule TagzUp.Repo.Migrations.CreateDisputes do
  use Ecto.Migration

  def up do
    create table(:disputes, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :booking_id, references(:bookings, type: :uuid, on_delete: :delete_all), null: false
      add :raised_by_user_id, references(:users, type: :uuid, on_delete: :restrict), null: false
      add :reason, :text, null: false
      add :description, :text, null: false
      add :evidence_urls, {:array, :text}, default: []
      add :status, :text, default: "open"
      add :resolution, :text
      add :resolved_by_user_id, references(:users, type: :uuid)
      add :resolved_at, :utc_datetime_usec

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create unique_index(:disputes, [:booking_id])
    create index(:disputes, [:raised_by_user_id])
    create index(:disputes, [:status])
    create index(:disputes, [:created_at])

    alter table(:disputes) do
      add_check_constraint(:reason_check, 
        "reason IN ('content_not_delivered', 'poor_quality', 'late_delivery', 'content_removed_early', 'payment_issue', 'other')")
      add_check_constraint(:status_check, 
        "status IN ('open', 'investigating', 'resolved', 'closed')")
    end

    execute "ALTER TABLE disputes ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Dispute participants can access disputes"
      ON disputes
      FOR ALL
      TO authenticated
      USING (
        raised_by_user_id = auth.uid() OR
        EXISTS (
          SELECT 1 FROM bookings b
          JOIN business_profiles bp ON bp.id = b.business_profile_id
          JOIN influencer_profiles ip ON ip.id = b.influencer_profile_id
          JOIN users bu ON bu.id = bp.user_id
          JOIN users iu ON iu.id = ip.user_id
          WHERE b.id = disputes.booking_id 
          AND (bu.id = auth.uid() OR iu.id = auth.uid())
        )
      )
    """

    execute """
    CREATE POLICY "Admins can manage all disputes"
      ON disputes
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
    drop table(:disputes)
  end
end