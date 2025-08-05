defmodule TagzUp.Bookings.Proof do
  use Ash.Resource,
    domain: TagzUp.Bookings,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "proofs"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :booking_id, :uuid, allow_nil?: false, public?: true
    attribute :platform, :atom do
      constraints one_of: [:instagram, :tiktok, :youtube, :facebook, :twitter, :linkedin]
      allow_nil? false
      public? true
    end
    attribute :post_url, :string, allow_nil?: false, public?: true
    attribute :screenshot_urls, {:array, :string}, default: [], public?: true
    attribute :post_id, :string, public?: true
    attribute :published_at, :utc_datetime, public?: true
    attribute :verification_status, :atom do
      constraints one_of: [:pending, :auto_verified, :manually_verified, :failed, :disputed]
      default :pending
      public? true
    end
    attribute :verification_data, :map, public?: true
    attribute :views_count, :integer, public?: true
    attribute :likes_count, :integer, public?: true
    attribute :comments_count, :integer, public?: true
    attribute :shares_count, :integer, public?: true
    attribute :verified_at, :utc_datetime, public?: true
    attribute :verified_by_user_id, :uuid, public?: true
    attribute :notes, :string, public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :booking, TagzUp.Bookings.Booking do
      attribute_writable? true
    end
  end

  actions do
    defaults [:read]
    default_accept [:platform, :post_url, :screenshot_urls, :notes]

    create :create do
      accept [:booking_id, :platform, :post_url, :screenshot_urls, :post_id, :published_at, :notes]
      primary? true
    end

    update :update do
      accept [:post_url, :screenshot_urls, :notes]
      primary? true
    end

    update :verify do
      accept [
        :verification_status, :verification_data, :views_count, :likes_count,
        :comments_count, :shares_count, :verified_at, :verified_by_user_id
      ]
    end

    read :by_status do
      argument :status, :atom, allow_nil?: false
      filter expr(verification_status == ^arg(:status))
    end

    read :pending_verification do
      filter expr(verification_status == :pending)
    end
  end

  code_interface do
    define :create
    define :update
    define :verify
    define :by_status, args: [:status]
    define :pending_verification
  end
end