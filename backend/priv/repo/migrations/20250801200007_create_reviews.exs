/*
  # Create reviews table

  1. New Tables
    - `reviews`
      - `id` (uuid, primary key)
      - `influencer_profile_id` (uuid, foreign key)
      - `business_profile_id` (uuid, foreign key)
      - `booking_id` (uuid, foreign key)
      - `rating` (integer, required, 1-5)
      - `comment` (text)
      - `is_public` (boolean, default true)
      - `created_at` (timestamptz)
      - `updated_at` (timestamptz)

  2. Security
    - Enable RLS on `reviews` table
    - Add policies for public read access to public reviews
    - Add policies for review participants to manage reviews
*/

defmodule TagzUp.Repo.Migrations.CreateReviews do
  use Ecto.Migration

  def up do
    create table(:reviews, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :influencer_profile_id, references(:influencer_profiles, type: :uuid, on_delete: :delete_all), null: false
      add :business_profile_id, references(:business_profiles, type: :uuid, on_delete: :delete_all), null: false
      add :booking_id, references(:bookings, type: :uuid, on_delete: :delete_all), null: false
      add :rating, :integer, null: false
      add :comment, :text
      add :is_public, :boolean, default: true

      add :created_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
      add :updated_at, :utc_datetime_usec, null: false, default: fragment("(now() AT TIME ZONE 'utc')")
    end

    create unique_index(:reviews, [:booking_id])
    create index(:reviews, [:influencer_profile_id])
    create index(:reviews, [:business_profile_id])
    create index(:reviews, [:rating])
    create index(:reviews, [:is_public])

    alter table(:reviews) do
      add_check_constraint(:rating_check, "rating >= 1 AND rating <= 5")
    end

    execute "ALTER TABLE reviews ENABLE ROW LEVEL SECURITY"

    execute """
    CREATE POLICY "Users can read public reviews"
      ON reviews
      FOR SELECT
      TO authenticated
      USING (is_public = true)
    """

    execute """
    CREATE POLICY "Review participants can manage reviews"
      ON reviews
      FOR ALL
      TO authenticated
      USING (EXISTS (
        SELECT 1 FROM business_profiles bp
        JOIN users bu ON bu.id = bp.user_id
        WHERE bp.id = reviews.business_profile_id 
        AND bu.id = auth.uid()
      ) OR EXISTS (
        SELECT 1 FROM influencer_profiles ip
        JOIN users iu ON iu.id = ip.user_id
        WHERE ip.id = reviews.influencer_profile_id 
        AND iu.id = auth.uid()
      ))
    """

    execute """
    CREATE POLICY "Admins can manage all reviews"
      ON reviews
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
    drop table(:reviews)
  end
end