defmodule TagzUp.Creators.SocialAccount do
  use Ash.Resource,
    domain: TagzUp.Creators,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "social_accounts"
    repo TagzUp.Repo
  end

  attributes do
    uuid_primary_key :id
    
    attribute :influencer_profile_id, :uuid, allow_nil?: false, public?: true
    attribute :platform, :atom do
      constraints one_of: [:instagram, :tiktok, :youtube, :facebook, :twitter, :linkedin]
      allow_nil? false
      public? true
    end
    attribute :username, :string, allow_nil?: false, public?: true
    attribute :profile_url, :string, allow_nil?: false, public?: true
    attribute :follower_count, :integer, default: 0, public?: true
    attribute :engagement_rate, :decimal, public?: true
    attribute :verification_status, :atom do
      constraints one_of: [:pending, :verified, :failed]
      default :pending
      public? true
    end
    attribute :last_verified_at, :utc_datetime, public?: true
    attribute :api_data, :map, public?: true
    
    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :influencer_profile, TagzUp.Creators.InfluencerProfile do
      attribute_writable? true
    end
  end

  actions do
    defaults [:read]
    default_accept [:platform, :username, :profile_url]

    create :create do
      accept [:influencer_profile_id, :platform, :username, :profile_url]
      primary? true
    end

    update :update do
      accept [:username, :profile_url]
      primary? true
    end

    update :update_metrics do
      accept [:follower_count, :engagement_rate, :verification_status, :last_verified_at, :api_data]
    end

    read :by_platform do
      argument :platform, :atom, allow_nil?: false
      filter expr(platform == ^arg(:platform))
    end

    read :verified do
      filter expr(verification_status == :verified)
    end
  end

  code_interface do
    define :create
    define :update
    define :update_metrics
    define :by_platform, args: [:platform]
    define :verified
  end
end