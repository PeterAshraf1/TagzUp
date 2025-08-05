defmodule TagzUp.Creators.InfluencerProfile do
  use Ash.Resource,
    domain: TagzUp.Creators,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "influencer_profiles"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :user_id, :uuid, allow_nil?: false, public?: true
    attribute :display_name, :string, allow_nil?: false, public?: true
    attribute :bio, :string, public?: true
    attribute :profile_image_url, :string, public?: true
    attribute :cover_image_url, :string, public?: true
    attribute :location, :string, public?: true
    attribute :languages, {:array, :string}, default: [], public?: true
    attribute :niches, {:array, :string}, default: [], public?: true
    attribute :total_followers, :integer, default: 0, public?: true
    attribute :avg_engagement_rate, :decimal, public?: true
    attribute :verification_status, :atom do
      constraints one_of: [:pending, :verified, :rejected]
      default :pending
      public? true
    end
    attribute :is_featured, :boolean, default: false, public?: true
    attribute :rating, :decimal, public?: true
    attribute :total_reviews, :integer, default: 0, public?: true
    attribute :total_bookings, :integer, default: 0, public?: true
    attribute :earnings, :decimal, default: 0, public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :user, TagzUp.Accounts.User do
      attribute_writable? true
    end
    
    has_many :social_accounts, TagzUp.Creators.SocialAccount
    has_many :packages, TagzUp.Creators.Package
    has_many :reviews, TagzUp.Creators.Review
  end

  actions do
    defaults [:read]
    default_accept [
      :display_name, :bio, :profile_image_url, :cover_image_url,
      :location, :languages, :niches, :is_featured
    ]

    create :create do
      accept [:user_id, :display_name, :bio, :profile_image_url, :location, :languages, :niches]
      primary? true
    end

    update :update do
      accept [:display_name, :bio, :profile_image_url, :cover_image_url, :location, :languages, :niches]
      primary? true
    end

    update :verify do
      accept [:verification_status]
    end

    update :update_stats do
      accept [:total_followers, :avg_engagement_rate, :rating, :total_reviews, :total_bookings, :earnings]
    end

    read :by_verification_status do
      argument :status, :atom, allow_nil?: false
      filter expr(verification_status == ^arg(:status))
    end

    read :featured do
      filter expr(is_featured == true and verification_status == :verified)
    end

    read :search do
      argument :query, :string
      argument :niches, {:array, :string}
      argument :min_followers, :integer
      argument :max_followers, :integer
      argument :min_engagement, :decimal
      argument :location, :string

      filter expr(
        if not is_nil(^arg(:query)) do
          contains(display_name, ^arg(:query)) or contains(bio, ^arg(:query))
        else
          true
        end and
        if not is_nil(^arg(:niches)) and length(^arg(:niches)) > 0 do
          fragment("? && ?", niches, ^arg(:niches))
        else
          true
        end and
        if not is_nil(^arg(:min_followers)) do
          total_followers >= ^arg(:min_followers)
        else
          true
        end and
        if not is_nil(^arg(:max_followers)) do
          total_followers <= ^arg(:max_followers)
        else
          true
        end and
        if not is_nil(^arg(:min_engagement)) do
          avg_engagement_rate >= ^arg(:min_engagement)
        else
          true
        end and
        if not is_nil(^arg(:location)) do
          contains(location, ^arg(:location))
        else
          true
        end and
        verification_status == :verified
      )
    end
  end

  code_interface do
    define :create
    define :update
    define :verify
    define :update_stats
    define :by_verification_status, args: [:status]
    define :featured
    define :search, args: [:query, :niches, :min_followers, :max_followers, :min_engagement, :location]
  end
end