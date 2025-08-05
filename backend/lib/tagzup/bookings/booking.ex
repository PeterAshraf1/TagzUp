defmodule TagzUp.Bookings.Booking do
  use Ash.Resource,
    domain: TagzUp.Bookings,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "bookings"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :business_profile_id, :uuid, allow_nil?: false, public?: true
    attribute :influencer_profile_id, :uuid, allow_nil?: false, public?: true
    attribute :package_id, :uuid, allow_nil?: false, public?: true
    attribute :status, :atom do
      constraints one_of: [
        :pending_payment, :paid, :in_progress, :pending_proof,
        :pending_verification, :completed, :cancelled, :disputed
      ]
      default :pending_payment
      public? true
    end
    attribute :total_amount, :decimal, allow_nil?: false, public?: true
    attribute :platform_fee, :decimal, allow_nil?: false, public?: true
    attribute :influencer_amount, :decimal, allow_nil?: false, public?: true
    attribute :currency, :string, default: "EGP", public?: true
    attribute :brief, :string, public?: true
    attribute :requirements, :string, public?: true
    attribute :deadline, :utc_datetime, public?: true
    attribute :started_at, :utc_datetime, public?: true
    attribute :completed_at, :utc_datetime, public?: true
    attribute :cancelled_at, :utc_datetime, public?: true
    attribute :cancellation_reason, :string, public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :business_profile, TagzUp.Business.BusinessProfile do
      attribute_writable? true
    end
    
    belongs_to :influencer_profile, TagzUp.Creators.InfluencerProfile do
      attribute_writable? true
    end
    
    belongs_to :package, TagzUp.Creators.Package do
      attribute_writable? true
    end

    has_many :payments, TagzUp.Bookings.Payment
    has_many :proofs, TagzUp.Bookings.Proof
    has_one :dispute, TagzUp.Bookings.Dispute
  end

  actions do
    defaults [:read]
    default_accept [:brief, :requirements, :deadline]

    create :create do
      accept [
        :business_profile_id, :influencer_profile_id, :package_id,
        :total_amount, :platform_fee, :influencer_amount, :currency,
        :brief, :requirements, :deadline
      ]
      primary? true
    end

    update :update do
      accept [:brief, :requirements, :deadline]
      primary? true
    end

    update :update_status do
      accept [:status, :started_at, :completed_at, :cancelled_at, :cancellation_reason]
    end

    read :by_status do
      argument :status, :atom, allow_nil?: false
      filter expr(status == ^arg(:status))
    end

    read :by_business do
      argument :business_profile_id, :uuid, allow_nil?: false
      filter expr(business_profile_id == ^arg(:business_profile_id))
    end

    read :by_influencer do
      argument :influencer_profile_id, :uuid, allow_nil?: false
      filter expr(influencer_profile_id == ^arg(:influencer_profile_id))
    end

    read :active do
      filter expr(status in [:paid, :in_progress, :pending_proof, :pending_verification])
    end
  end

  code_interface do
    define :create
    define :update
    define :update_status
    define :by_status, args: [:status]
    define :by_business, args: [:business_profile_id]
    define :by_influencer, args: [:influencer_profile_id]
    define :active
  end
end